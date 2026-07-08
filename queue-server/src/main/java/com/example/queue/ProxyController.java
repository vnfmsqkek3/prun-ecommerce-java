package com.example.queue;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;

import java.util.Collections;
import java.util.Set;

/**
 * 리버스 프록시 — 대기열 서버가 API 백엔드 앞단에 위치.
 *   CloudFront → ALB1 → (이 서버) → ALB2 → API 백엔드
 * /api/queue/** 는 {@link QueueController} 가 처리(더 구체적 패턴이라 우선 매칭),
 * 그 외 /api/** 는 내부 ALB2(백엔드)로 메서드/헤더/쿼리/바디 그대로 포워딩(투명 프록시).
 * /actuator/** 는 이 서버 자신의 헬스라 프록시하지 않음(ALB1 헬스체크용).
 */
@RestController
public class ProxyController {

    /** RestClient 가 오리진에서 다시 세팅하는 hop-by-hop 헤더는 전달하지 않음. */
    private static final Set<String> SKIP_HEADERS =
            Set.of("host", "content-length", "connection", "transfer-encoding");

    private final RestClient client;

    public ProxyController(@Value("${backend.url:http://localhost:8080}") String backendUrl) {
        this.client = RestClient.builder().baseUrl(backendUrl).build();
    }

    @RequestMapping("/api/**")
    public ResponseEntity<byte[]> proxy(HttpServletRequest request,
                                        @RequestBody(required = false) byte[] body) {
        String uri = request.getRequestURI()
                + (request.getQueryString() != null ? "?" + request.getQueryString() : "");

        return client.method(HttpMethod.valueOf(request.getMethod()))
                .uri(uri)
                .headers(h -> copyRequestHeaders(request, h))
                .body(body == null ? new byte[0] : body)
                .exchange((req, res) -> {
                    HttpHeaders respHeaders = new HttpHeaders();
                    res.getHeaders().forEach((name, values) -> {
                        if (!SKIP_HEADERS.contains(name.toLowerCase())) {
                            respHeaders.put(name, values);
                        }
                    });
                    return ResponseEntity.status(res.getStatusCode())
                            .headers(respHeaders)
                            .body(res.getBody().readAllBytes());
                }); // exchange 는 4xx/5xx 도 예외 없이 그대로 전달(retrieve 와 다름). 응답 자동 close.
    }

    private void copyRequestHeaders(HttpServletRequest request, HttpHeaders out) {
        for (String name : Collections.list(request.getHeaderNames())) {
            if (!SKIP_HEADERS.contains(name.toLowerCase())) {
                out.put(name, Collections.list(request.getHeaders(name)));
            }
        }
    }
}
