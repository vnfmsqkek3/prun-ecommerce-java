package com.example.ticketing.dto;

import com.example.ticketing.domain.Concert;
import com.example.ticketing.domain.Seat;
import com.example.ticketing.domain.SeatStatus;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 요청/응답 DTO 모음 */
public class Dtos {

    public record ConcertDto(Long id, String title, String artist, String venue,
                             LocalDateTime concertDate, String imageUrl) {
        public static ConcertDto from(Concert c) {
            return new ConcertDto(c.getId(), c.getTitle(), c.getArtist(), c.getVenue(),
                    c.getConcertDate(), c.getImageUrl());
        }
    }

    public record SeatDto(Long id, String seatNo, String grade, BigDecimal price, SeatStatus status) {
        public static SeatDto from(Seat s) {
            return new SeatDto(s.getId(), s.getSeatNo(), s.getGrade(), s.getPrice(), s.getStatus());
        }
    }

    public record ReservationRequest(
            @NotNull Long concertId,
            @NotNull Long seatId,
            @NotBlank String userId,
            @NotBlank String token,                 // 대기열 입장 토큰
            @NotBlank @Email String email,          // 로그인 없이 예약조회 키
            @NotBlank String phone,                 // 카카오 알림톡 발송 대상
            String paymentMethod                    // CARD / KAKAOPAY / TOSS (기본 CARD)
    ) {}

    /** 예약 + 결제 + 공연/좌석 정보 (예약완료 응답 및 예약조회에 공용) */
    public record ReservationDto(
            Long id, Long concertId, String concertTitle, LocalDateTime concertDate,
            String seatNo, String grade, BigDecimal amount,
            String paymentMethod, String transactionId, String paymentStatus,
            String email, LocalDateTime createdAt
    ) {}
}
