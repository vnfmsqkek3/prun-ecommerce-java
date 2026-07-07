package com.example.ticketing.service;

import com.example.ticketing.domain.Concert;
import com.example.ticketing.dto.Dtos.ConcertDto;
import com.example.ticketing.dto.Dtos.SeatDto;
import com.example.ticketing.repository.ConcertRepository;
import com.example.ticketing.repository.SeatRepository;
import com.example.ticketing.web.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class ConcertService {

    private final ConcertRepository concertRepository;
    private final SeatRepository seatRepository;

    public ConcertService(ConcertRepository concertRepository, SeatRepository seatRepository) {
        this.concertRepository = concertRepository;
        this.seatRepository = seatRepository;
    }

    public List<ConcertDto> list() {
        return concertRepository.findAll().stream().map(ConcertDto::from).toList();
    }

    public ConcertDto get(Long id) {
        Concert c = concertRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "콘서트를 찾을 수 없습니다"));
        return ConcertDto.from(c);
    }

    public List<SeatDto> seats(Long concertId) {
        return seatRepository.findByConcertIdOrderBySeatNo(concertId).stream()
                .map(SeatDto::from).toList();
    }
}
