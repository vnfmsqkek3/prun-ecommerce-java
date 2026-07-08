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
 * 인메모리 대기열 (기본, 외부 의존 없음).
 * 흐름: waiting(FIFO) → active(만료시각 보유). 슬롯이 비면 다음 대기자 즉시 승격.
 *   - 예약완료(complete) → 슬롯 즉시 회수 → 다음 대기자 바로 입장 (핵심 경로)
 *   - active TTL 만료 → 이탈한 슬롯 회수 (비상장치)
 *   - 스케줄러 → 위 상황을 짧은 주기로 반영
 */
@Service
@Profile("!redis")
public class InMemoryQueueService implements QueueService {

    private final Map<Long, ConcurrentLinkedQueue<String>> waiting = new ConcurrentHashMap<>();
    private final Map<Long, Map<String, Long>> active = new ConcurrentHashMap<>();

    @Value("${queue.capacity:3}")
    private int capacity;
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

    /** 예약완료/취소 → 슬롯 즉시 회수 + 다음 대기자 바로 승격 */
    @Override
    public synchronized void complete(Long concertId, String token) {
        activeMap(concertId).remove(token);
        promoteConcert(concertId, Instant.now().toEpochMilli());
    }

    @Override
    public synchronized void leave(Long concertId, String token) {
        boolean wasActive = activeMap(concertId).remove(token) != null;
        waitQueue(concertId).remove(token);
        // 활성 슬롯을 반납했으면 다음 대기자 승격. 대기만 하다 나간 경우는 인원만 감소.
        if (wasActive) promoteConcert(concertId, Instant.now().toEpochMilli());
    }

    @Override
    public synchronized void promoteAll() {
        long now = Instant.now().toEpochMilli();
        for (Long concertId : new ArrayList<>(waiting.keySet())) {
            promoteConcert(concertId, now);
        }
    }

    /** capacity 가 찰 때까지 대기열 앞에서부터 입장시킴 */
    private void promoteConcert(Long concertId, long now) {
        cleanExpired(concertId, now);
        while (activeMap(concertId).size() < capacity) {
            String t = waitQueue(concertId).poll();
            if (t == null) break;
            admit(concertId, t, now);
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
