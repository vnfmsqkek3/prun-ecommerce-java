package com.example.queue;

/**
 * status: ONGOING(입장=예약가능) | WAIT(대기중) | EXPIRED(만료/없음)
 * position: 대기중일 때 내 순번(1부터), 아니면 null
 * waitingTotal: 현재 대기 인원
 * expiresAt: 입장 상태일 때 만료 시각(epoch ms)
 */
public record TokenStatus(
        String token,
        String status,
        Long position,
        Long waitingTotal,
        Long expiresAt
) {}
