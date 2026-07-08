package com.example.ticketing.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Map;

/** 별도 대기열 서버에 토큰 유효성 확인 / 예약완료 후 슬롯 반납 요청 */
@Component
public class QueueClient {

    private final RestClient client;

    public QueueClient(@Value("${queue-server.url:http://localhost:8081}") String baseUrl) {
        // 타임아웃 필수 — 큐 미도달 시 무한 대기하면 예약 요청 전체가 hang 된다.
        // 초과 시 예외 → isValid()=false(403) 로 빠르게 실패.
        SimpleClientHttpRequestFactory rf = new SimpleClientHttpRequestFactory();
        rf.setConnectTimeout(2000);
        rf.setReadTimeout(3000);
        this.client = RestClient.builder().baseUrl(baseUrl).requestFactory(rf).build();
    }

    public boolean isValid(Long concertId, String token) {
        try {
            Map<?, ?> res = client.get()
                    .uri("/api/queue/{cid}/validate?token={t}", concertId, token)
                    .retrieve()
                    .body(Map.class);
            return res != null && Boolean.TRUE.equals(res.get("valid"));
        } catch (Exception e) {
            return false;
        }
    }

    public void complete(Long concertId, String token) {
        try {
            client.post()
                    .uri("/api/queue/{cid}/complete?token={t}", concertId, token)
                    .retrieve()
                    .toBodilessEntity();
        } catch (Exception ignored) {
            // 반납 실패는 치명적 아님 (TTL 로 자동 만료)
        }
    }
}
