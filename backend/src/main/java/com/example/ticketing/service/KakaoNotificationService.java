package com.example.ticketing.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 카카오 알림톡(예약 확정 카톡 알람).
 * 로컬: app.kakao.api-url 미설정 → 콘솔에 발송 내용 로그.
 * AWS/운영: 알림톡 제공사(Solapi/NHN Cloud 등) REST API 를 app.kakao.* 로 주입 → 실제 발송.
 * @Async — 예약 응답이 외부 API 지연에 막히지 않도록 비동기.
 */
@Service
public class KakaoNotificationService {

    private static final Logger log = LoggerFactory.getLogger(KakaoNotificationService.class);

    @Value("${app.kakao.api-url:}")
    private String apiUrl;
    @Value("${app.kakao.api-key:}")
    private String apiKey;
    @Value("${app.kakao.sender-key:}")
    private String senderKey;      // 발신 카카오 채널 sender key
    @Value("${app.kakao.template-code:}")
    private String templateCode;   // 승인된 알림톡 템플릿 코드

    @Async
    public void sendReservationConfirmation(String phone, String concertTitle, String seatNo,
                                            BigDecimal amount, String transactionId) {
        String text = """
                [콘서트 티켓팅] 예약이 확정되었습니다 🎫
                공연: %s
                좌석: %s
                결제금액: %,d원
                승인번호: %s
                예약현황은 사이트 '예약확인'에서 이메일로 조회하세요.""".formatted(
                concertTitle, seatNo, amount.longValue(), transactionId);

        if (apiUrl == null || apiUrl.isBlank()) {
            // 로컬: 제공사 미설정 → 발송 대신 로그
            log.info("[KAKAO:LOG-ONLY] to={} \n{}", phone, text);
            return;
        }
        try {
            RestClient.create().post()
                    .uri(apiUrl)
                    .header("Authorization", "Bearer " + apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of(
                            "to", phone,
                            "senderKey", senderKey,
                            "templateCode", templateCode,
                            "text", text))
                    .retrieve()
                    .toBodilessEntity();
            log.info("카카오 알림톡 발송 완료 to={}", phone);
        } catch (Exception e) {
            log.warn("카카오 알림톡 발송 실패 to={} : {}", phone, e.getMessage());
        }
    }
}
