package com.example.queue;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * 인메모리 대기열 (기본, 외부 의존 없음 → 코드로 바로 실행).
 * 동작은 Redis 구현과 동일한 의미: waiting(FIFO=진입순) → active(만료시각 보유).
 * 단일 인스턴스 전용(스케일아웃 시 Redis 구현으로 전환).
 */
@Service
@Profile("!redis")
public class InMemoryQueueService implements QueueService {

    private final Map<Long, ConcurrentLinkedQueue<String>> waiting = new ConcurrentHashMap<>();
    private final Map<Long, Map<String, Long>> active = new ConcurrentHashMap<>(); // token -> 만료시각(ms)

    @Value("${queue.capacity:3}")
    private int capacity;
    @Value("${queue.admit-batch:1}")
    private int admitBatch;
    @Value("${queue.active-ttl-seconds:600}")
    private long activeTtlSeconds;

    @Override
    public synchronized TokenStatus enter(Long concertId, String userId) {
        String token = UUID.randomUUID().toString();
        long now = Instant.now().toEpochMilli();
        cleanExpired(concertId, now);
        if (activeMap(concertId).size() < capacity) {
            admit(concertId, token, now);
            return new TokenStatus(token, "ONGOING", null, 0L, now + activeTtlSeconds * 1000);
        }
        waitQueue(concertId).add(token);
        return status(concertId, token);
    }

    @Override
    public synchronized TokenStatus status(Long concertId, String token) {
        long now = Instant.now().toEpochMilli();
        Long exp = activeMap(concertId).get(token);
        long waitingTotal = waitQueue(concertId).size();
        if (exp != null && exp > now) {
            return new TokenStatus(token, "ONGOING", null, waitingTotal, exp);
        }
        List<String> list = new ArrayList<>(waitQueue(concertId));
        int idx = list.indexOf(token);
        if (idx >= 0) {
            return new TokenStatus(token, "WAIT", (long) (idx + 1), waitingTotal, null);
        }
        return new TokenStatus(token, "EXPIRED", null, 0L, null);
    }

    @Override
    public synchronized boolean validate(Long concertId, String token) {
        Long exp = activeMap(concertId).get(token);
        return exp != null && exp > Instant.now().toEpochMilli();
    }

    @Override
    public synchronized void complete(Long concertId, String token) {
        activeMap(concertId).remove(token);
    }

    @Override
    public synchronized void promoteAll() {
        long now = Instant.now().toEpochMilli();
        for (Long concertId : new ArrayList<>(waiting.keySet())) {
            cleanExpired(concertId, now);
            long slots = capacity - activeMap(concertId).size();
            long toAdmit = Math.min(slots, admitBatch);
            for (long i = 0; i < toAdmit; i++) {
                String token = waitQueue(concertId).poll();
                if (token == null) break;
                admit(concertId, token, now);
            }
        }
    }

    private void admit(Long concertId, String token, long now) {
        activeMap(concertId).put(token, now + activeTtlSeconds * 1000);
    }

    private void cleanExpired(Long concertId, long now) {
        activeMap(concertId).entrySet().removeIf(e -> e.getValue() <= now);
    }

    private ConcurrentLinkedQueue<String> waitQueue(Long concertId) {
        return waiting.computeIfAbsent(concertId, k -> new ConcurrentLinkedQueue<>());
    }

    private Map<String, Long> activeMap(Long concertId) {
        return active.computeIfAbsent(concertId, k -> new ConcurrentHashMap<>());
    }
}
