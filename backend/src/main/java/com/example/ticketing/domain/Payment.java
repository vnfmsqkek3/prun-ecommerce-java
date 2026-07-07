package com.example.ticketing.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter
@NoArgsConstructor
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "reservation_id", nullable = false)
    private Long reservationId;

    private BigDecimal amount;

    private String method; // CARD, KAKAOPAY, TOSS ...

    @Enumerated(EnumType.STRING)
    private PaymentStatus status;

    @Column(name = "transaction_id")
    private String transactionId; // 가상 PG 승인번호

    private LocalDateTime paidAt;

    public Payment(Long reservationId, BigDecimal amount, String method,
                   PaymentStatus status, String transactionId) {
        this.reservationId = reservationId;
        this.amount = amount;
        this.method = method;
        this.status = status;
        this.transactionId = transactionId;
        this.paidAt = LocalDateTime.now();
    }
}
