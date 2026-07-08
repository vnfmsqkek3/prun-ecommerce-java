package com.example.queue;

import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 대기열 API
 *   POST /api/queue/{concertId}/enter?userId=   → 토큰 발급 + 대기/입장
 *   GET  /api/queue/{concertId}/status?token=    → 내 순번/입장여부 폴링
 *   GET  /api/queue/{concertId}/validate?token=  → (백엔드용) 예약 가능 토큰인지
 *   POST /api/queue/{concertId}/complete?token=  → 예약 완료 후 슬롯 반납
 */
@RestController
@RequestMapping("/api/queue")
@CrossOrigin(originPatterns = "*")
public class QueueController {

    private final QueueService service;

    public QueueController(QueueService service) {
        this.service = service;
    }

    @PostMapping("/{concertId}/enter")
    public TokenStatus enter(@PathVariable Long concertId,
                             @RequestParam(defaultValue = "anonymous") String userId) {
        return service.enter(concertId, userId);
    }

    @GetMapping("/{concertId}/status")
    public TokenStatus status(@PathVariable Long concertId, @RequestParam String token) {
        return service.status(concertId, token);
    }

    @GetMapping("/{concertId}/validate")
    public Map<String, Boolean> validate(@PathVariable Long concertId, @RequestParam String token) {
        return Map.of("valid", service.validate(concertId, token));
    }

    @PostMapping("/{concertId}/complete")
    public void complete(@PathVariable Long concertId, @RequestParam String token) {
        service.complete(concertId, token);
    }

    /** 대기/입장 중 이탈 — 대기열에서 제거(대기 인원 감소). sendBeacon 으로도 호출됨. */
    @PostMapping("/{concertId}/leave")
    public void leave(@PathVariable Long concertId, @RequestParam String token) {
        service.leave(concertId, token);
    }
}
