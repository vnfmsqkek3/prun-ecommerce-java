package com.example.queue;

/**
 * 대기열 서비스. 구현 2종:
 *   - InMemoryQueueService (기본) : 외부 의존 없이 코드로 바로 실행
 *   - RedisQueueService ("redis" 프로파일) : ElastiCache/Redis Sorted Set (운영/스케일아웃)
 */
public interface QueueService {
    TokenStatus enter(Long concertId, String userId);
    TokenStatus status(Long concertId, String token);
    boolean validate(Long concertId, String token);
    void complete(Long concertId, String token);

    /** 대기/입장 중 이탈 — 토큰을 대기열/활성에서 제거(대기 인원 감소), 슬롯 비면 다음 대기자 승격 */
    void leave(Long concertId, String token);

    void promoteAll();
}
