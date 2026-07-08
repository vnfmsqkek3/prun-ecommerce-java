package com.example.queue;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

/**
 * Redis Sorted Set 기반 대기열 ("redis" 프로파일, 스케일아웃/운영용).
 *   waiting:concert:{id}  ZSET  member=token, score=진입시각(ms)
 *   active:concert:{id}   ZSET  member=token, score=만료시각(ms)
 * complete(예약완료) → 슬롯 즉시 회수 + 다음 대기자 바로 승격.
 */
@Service
@Profile("redis")
public class RedisQueueService implements QueueService {

    private static final String WAITING = "waiting:concert:";
    private static final String ACTIVE = "active:concert:";
    private static final String CONCERTS = "queue:concerts";

    private final StringRedisTemplate redis;

    @Value("${queue.capacity:3}")
    private int capacity;
    @Value("${queue.active-ttl-seconds:600}")
    private long activeTtlSeconds;

    public RedisQueueService(StringRedisTemplate redis) {
        this.redis = redis;
    }

    @Override
    public TokenStatus enter(Long concertId, String userId) {
        String token = UUID.randomUUID().toString();
        redis.opsForSet().add(CONCERTS, String.valueOf(concertId));
        long now = Instant.now().toEpochMilli();
        cleanExpired(concertId, now);
        Long activeCount = redis.opsForZSet().zCard(active(concertId));
        if (activeCount != null && activeCount < capacity) {
            admit(concertId, token, now);
            return new TokenStatus(token, "ONGOING", null, 0L, now + activeTtlSeconds * 1000);
        }
        redis.opsForZSet().add(waiting(concertId), token, now);
        return status(concertId, token);
    }

    @Override
    public TokenStatus status(Long concertId, String token) {
        long now = Instant.now().toEpochMilli();
        Double exp = redis.opsForZSet().score(active(concertId), token);
        if (exp != null && exp > now) {
            return new TokenStatus(token, "ONGOING", null, redis.opsForZSet().zCard(waiting(concertId)), exp.longValue());
        }
        Long rank = redis.opsForZSet().rank(waiting(concertId), token);
        if (rank != null) {
            return new TokenStatus(token, "WAIT", rank + 1, redis.opsForZSet().zCard(waiting(concertId)), null);
        }
        return new TokenStatus(token, "EXPIRED", null, 0L, null);
    }

    @Override
    public boolean validate(Long concertId, String token) {
        Double exp = redis.opsForZSet().score(active(concertId), token);
        return exp != null && exp > Instant.now().toEpochMilli();
    }

    @Override
    public void complete(Long concertId, String token) {
        redis.opsForZSet().remove(active(concertId), token);
        promoteConcert(concertId, Instant.now().toEpochMilli());
    }

    @Override
    public void leave(Long concertId, String token) {
        Long removedActive = redis.opsForZSet().remove(active(concertId), token);
        redis.opsForZSet().remove(waiting(concertId), token);
        // 활성 슬롯을 반납했으면 다음 대기자 승격. 대기만 하다 나간 경우는 인원만 감소.
        if (removedActive != null && removedActive > 0) {
            promoteConcert(concertId, Instant.now().toEpochMilli());
        }
    }

    @Override
    public void promoteAll() {
        Set<String> concerts = redis.opsForSet().members(CONCERTS);
        if (concerts == null) return;
        long now = Instant.now().toEpochMilli();
        for (String c : concerts) promoteConcert(Long.parseLong(c), now);
    }

    private void promoteConcert(long concertId, long now) {
        cleanExpired(concertId, now);
        Long activeCount = redis.opsForZSet().zCard(active(concertId));
        long slots = capacity - (activeCount == null ? 0 : activeCount);
        if (slots > 0) {
            Set<ZSetOperations.TypedTuple<String>> popped =
                    redis.opsForZSet().popMin(waiting(concertId), slots);
            if (popped != null) {
                for (ZSetOperations.TypedTuple<String> t : popped) {
                    if (t.getValue() != null) admit(concertId, t.getValue(), now);
                }
            }
        }
        Long remaining = redis.opsForZSet().zCard(waiting(concertId));
        if (remaining == null || remaining == 0) redis.opsForSet().remove(CONCERTS, String.valueOf(concertId));
    }

    private void admit(long concertId, String token, long now) {
        redis.opsForZSet().add(active(concertId), token, now + activeTtlSeconds * 1000);
    }

    private void cleanExpired(long concertId, long now) {
        redis.opsForZSet().removeRangeByScore(active(concertId), 0, now);
    }

    private String waiting(long concertId) { return WAITING + concertId; }
    private String active(long concertId) { return ACTIVE + concertId; }
}
