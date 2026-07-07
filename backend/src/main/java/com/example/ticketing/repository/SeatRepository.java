package com.example.ticketing.repository;

import com.example.ticketing.domain.Seat;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SeatRepository extends JpaRepository<Seat, Long> {

    List<Seat> findByConcertIdOrderBySeatNo(Long concertId);

    // 비관적 락(SELECT ... FOR UPDATE) — 같은 좌석 동시 예약 시 한 트랜잭션만 진행, 중복예약 방지
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select s from Seat s where s.id = :id")
    Optional<Seat> findByIdForUpdate(@Param("id") Long id);
}
