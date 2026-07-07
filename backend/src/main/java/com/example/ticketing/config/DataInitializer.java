package com.example.ticketing.config;

import com.example.ticketing.domain.Concert;
import com.example.ticketing.domain.Seat;
import com.example.ticketing.repository.ConcertRepository;
import com.example.ticketing.repository.SeatRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** 콘서트/좌석 시드 (빈 DB일 때만). 좌석: 5행(A~E) × 10석 = 50석. */
@Component
public class DataInitializer implements CommandLineRunner {

    private final ConcertRepository concertRepository;
    private final SeatRepository seatRepository;

    public DataInitializer(ConcertRepository concertRepository, SeatRepository seatRepository) {
        this.concertRepository = concertRepository;
        this.seatRepository = seatRepository;
    }

    @Override
    public void run(String... args) {
        if (concertRepository.count() > 0) return;

        String[][] data = {
                {"2026 IU Concert : The Golden Hour", "아이유", "잠실 주경기장", "iu"},
                {"BTS World Tour in Seoul", "BTS", "고척 스카이돔", "bts"},
                {"NewJeans Fan Meeting", "뉴진스", "KSPO DOME", "newjeans"},
        };
        int month = 3;
        for (String[] d : data) {
            Concert c = concertRepository.save(new Concert(
                    d[0], d[1], d[2],
                    LocalDateTime.of(2026, month++, 15, 19, 0),
                    "https://picsum.photos/seed/" + d[3] + "/600/400"));
            seatRepository.saveAll(makeSeats(c.getId()));
        }
    }

    private List<Seat> makeSeats(Long concertId) {
        List<Seat> seats = new ArrayList<>();
        String[] rows = {"A", "B", "C", "D", "E"};
        for (String row : rows) {
            String grade;
            BigDecimal price;
            switch (row) {
                case "A" -> { grade = "VIP"; price = new BigDecimal("150000"); }
                case "B", "C" -> { grade = "R"; price = new BigDecimal("120000"); }
                default -> { grade = "S"; price = new BigDecimal("90000"); }
            }
            for (int n = 1; n <= 10; n++) {
                seats.add(new Seat(concertId, row + n, grade, price));
            }
        }
        return seats;
    }
}
