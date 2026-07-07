package com.example.ticketing.repository;

import com.example.ticketing.domain.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByEmailOrderByCreatedAtDesc(String email);
    boolean existsBySeatId(Long seatId);
}
