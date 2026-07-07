package com.example.ticketing.service;

import com.example.ticketing.domain.Payment;
import com.example.ticketing.domain.PaymentStatus;
import com.example.ticketing.repository.PaymentRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

/** 가상 결제 — 실제 PG 없이 항상 승인 처리하고 결제내역을 DB 에 저장 */
@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;

    public PaymentService(PaymentRepository paymentRepository) {
        this.paymentRepository = paymentRepository;
    }

    public Payment pay(Long reservationId, BigDecimal amount, String method) {
        String txId = "PG-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase();
        // 가상 승인 (실제 연동 시 PG 호출 결과로 status 결정)
        Payment payment = new Payment(reservationId, amount,
                method == null ? "CARD" : method, PaymentStatus.PAID, txId);
        return paymentRepository.save(payment);
    }
}
