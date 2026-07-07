package com.example.ticketing.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "reservations", indexes = @Index(name = "idx_email", columnList = "email"))
@Getter
@NoArgsConstructor
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "concert_id", nullable = false)
    private Long concertId;

    @Column(name = "seat_id", nullable = false)
    private Long seatId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    // 로그인 없이 이메일로 예약현황 조회
    @Column(nullable = false)
    private String email;

    // 카카오 알림톡 발송 대상 번호
    private String phone;

    private LocalDateTime createdAt = LocalDateTime.now();

    public Reservation(Long concertId, Long seatId, String userId, String email, String phone) {
        this.concertId = concertId;
        this.seatId = seatId;
        this.userId = userId;
        this.email = email;
        this.phone = phone;
        this.createdAt = LocalDateTime.now();
    }
}
