package com.example.queue;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** 블로그: 10초마다 대기열에서 active 로 배치 승격 */
@Component
public class QueueScheduler {

    private final QueueService service;

    public QueueScheduler(QueueService service) {
        this.service = service;
    }

    @Scheduled(fixedRateString = "${queue.scheduler-ms:10000}")
    public void promote() {
        service.promoteAll();
    }
}
