package com.example.ticketing.web;

import com.example.ticketing.dto.Dtos.ConcertDto;
import com.example.ticketing.dto.Dtos.SeatDto;
import com.example.ticketing.service.ConcertService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/concerts")
public class ConcertController {

    private final ConcertService service;

    public ConcertController(ConcertService service) {
        this.service = service;
    }

    @GetMapping
    public List<ConcertDto> list() {
        return service.list();
    }

    @GetMapping("/{id}")
    public ConcertDto get(@PathVariable Long id) {
        return service.get(id);
    }

    @GetMapping("/{id}/seats")
    public List<SeatDto> seats(@PathVariable Long id) {
        return service.seats(id);
    }
}
