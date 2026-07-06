package com.example.ecommercedemo.controller;

import com.example.ecommercedemo.dto.OrderCreateDto;
import com.example.ecommercedemo.dto.OrderDto;
import com.example.ecommercedemo.dto.OrderStatusUpdateDto;
import com.example.ecommercedemo.entity.OrderStatus;
import com.example.ecommercedemo.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<OrderDto> insertOrder(@Valid @RequestBody OrderCreateDto dto) {
        OrderDto order = orderService.insertOrder(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(order);
    }

    @PostMapping("/from-cart")
    public ResponseEntity<OrderDto> insertOrderFromCart(@RequestHeader("X-User-Id") Long userId) {
        OrderDto order = orderService.insertOrderFromCart(userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(order);
    }

    @GetMapping
    public ResponseEntity<Page<OrderDto>> selectOrderList(
            @RequestParam Long userId,
            @RequestParam(required = false) OrderStatus status,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        
        Page<OrderDto> orders = status != null
                ? orderService.selectOrderListByStatus(userId, status, pageable)
                : orderService.selectOrderList(userId, pageable);
        
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderDto> selectOrder(@PathVariable Long id) {
        OrderDto order = orderService.selectOrder(id);
        return ResponseEntity.ok(order);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<OrderDto> updateOrderStatus(
            @PathVariable Long id,
            @Valid @RequestBody OrderStatusUpdateDto dto) {
        OrderDto order = orderService.updateOrderStatus(id, dto);
        return ResponseEntity.ok(order);
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<OrderDto> cancelOrder(@PathVariable Long id) {
        OrderDto order = orderService.cancelOrder(id);
        return ResponseEntity.ok(order);
    }
}
