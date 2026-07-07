package com.example.ticketing.service;

import com.example.ticketing.client.QueueClient;
import com.example.ticketing.domain.Concert;
import com.example.ticketing.domain.Payment;
import com.example.ticketing.domain.Reservation;
import com.example.ticketing.domain.Seat;
import com.example.ticketing.dto.Dtos.ReservationDto;
import com.example.ticketing.dto.Dtos.ReservationRequest;
import com.example.ticketing.repository.ConcertRepository;
import com.example.ticketing.repository.PaymentRepository;
import com.example.ticketing.repository.ReservationRepository;
import com.example.ticketing.repository.SeatRepository;
import com.example.ticketing.web.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class ReservationService {

    private final SeatRepository seatRepository;
    private final ReservationRepository reservationRepository;
    private final ConcertRepository concertRepository;
    private final PaymentRepository paymentRepository;
    private final PaymentService paymentService;
    private final KakaoNotificationService kakao;
    private final QueueClient queueClient;

    public ReservationService(SeatRepository seatRepository, ReservationRepository reservationRepository,
                              ConcertRepository concertRepository, PaymentRepository paymentRepository,
                              PaymentService paymentService, KakaoNotificationService kakao,
                              QueueClient queueClient) {
        this.seatRepository = seatRepository;
        this.reservationRepository = reservationRepository;
        this.concertRepository = concertRepository;
        this.paymentRepository = paymentRepository;
        this.paymentService = paymentService;
        this.kakao = kakao;
        this.queueClient = queueClient;
    }

    @Transactional
    public ReservationDto reserve(ReservationRequest req) {
        // 1) 대기열 입장 토큰 검증
        if (!queueClient.isValid(req.concertId(), req.token())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "대기열 입장 토큰이 유효하지 않습니다");
        }

        // 2) 좌석 비관적 락 → 중복예약 방지
        Seat seat = seatRepository.findByIdForUpdate(req.seatId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "좌석을 찾을 수 없습니다"));
        if (!seat.getConcertId().equals(req.concertId())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "콘서트와 좌석이 일치하지 않습니다");
        }
        if (!seat.isAvailable()) {
            throw new ApiException(HttpStatus.CONFLICT, "이미 예약된 좌석입니다");
        }
        seat.reserve();

        // 3) 예약 + 가상 결제(DB 저장)
        Reservation r = reservationRepository.save(
                new Reservation(req.concertId(), req.seatId(), req.userId(), req.email(), req.phone()));
        Payment payment = paymentService.pay(r.getId(), seat.getPrice(), req.paymentMethod());

        // 4) 대기열 슬롯 반납
        queueClient.complete(req.concertId(), req.token());

        // 5) 카카오 알림톡 발송 (비동기)
        Concert concert = concertRepository.findById(req.concertId()).orElse(null);
        String title = concert != null ? concert.getTitle() : "공연";
        kakao.sendReservationConfirmation(req.phone(), title, seat.getSeatNo(),
                payment.getAmount(), payment.getTransactionId());

        return toDto(r, seat, concert, payment);
    }

    /** 로그인 없이 이메일로 예약현황 조회 */
    @Transactional(readOnly = true)
    public List<ReservationDto> findByEmail(String email) {
        List<Reservation> reservations = reservationRepository.findByEmailOrderByCreatedAtDesc(email);
        if (reservations.isEmpty()) return List.of();

        Map<Long, Seat> seats = seatRepository.findAllById(
                reservations.stream().map(Reservation::getSeatId).toList())
                .stream().collect(Collectors.toMap(Seat::getId, Function.identity()));
        Map<Long, Concert> concerts = concertRepository.findAllById(
                reservations.stream().map(Reservation::getConcertId).toList())
                .stream().collect(Collectors.toMap(Concert::getId, Function.identity()));
        Map<Long, Payment> payments = paymentRepository.findByReservationIdIn(
                reservations.stream().map(Reservation::getId).toList())
                .stream().collect(Collectors.toMap(Payment::getReservationId, Function.identity()));

        return reservations.stream()
                .map(r -> toDto(r, seats.get(r.getSeatId()), concerts.get(r.getConcertId()),
                        payments.get(r.getId())))
                .toList();
    }

    private ReservationDto toDto(Reservation r, Seat seat, Concert concert, Payment payment) {
        return new ReservationDto(
                r.getId(),
                r.getConcertId(),
                concert != null ? concert.getTitle() : null,
                concert != null ? concert.getConcertDate() : null,
                seat != null ? seat.getSeatNo() : null,
                seat != null ? seat.getGrade() : null,
                payment != null ? payment.getAmount() : (seat != null ? seat.getPrice() : null),
                payment != null ? payment.getMethod() : null,
                payment != null ? payment.getTransactionId() : null,
                payment != null ? payment.getStatus().name() : null,
                r.getEmail(),
                r.getCreatedAt());
    }
}
