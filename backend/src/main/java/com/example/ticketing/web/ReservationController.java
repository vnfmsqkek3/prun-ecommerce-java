package com.example.ticketing.web;

import com.example.ticketing.dto.Dtos.ReservationDto;
import com.example.ticketing.dto.Dtos.ReservationRequest;
import com.example.ticketing.service.ReservationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    private final ReservationService service;

    public ReservationController(ReservationService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<ReservationDto> reserve(@Valid @RequestBody ReservationRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.reserve(req));
    }

    // 로그인 없이 이메일로 예약현황 조회
    @GetMapping
    public List<ReservationDto> byEmail(@RequestParam String email) {
        return service.findByEmail(email);
    }
}
