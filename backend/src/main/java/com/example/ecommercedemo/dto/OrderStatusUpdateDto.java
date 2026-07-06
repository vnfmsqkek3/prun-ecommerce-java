package com.example.ecommercedemo.dto;

import com.example.ecommercedemo.entity.OrderStatus;
import jakarta.validation.constraints.NotNull;

public class OrderStatusUpdateDto {

    @NotNull(message = "주문 상태는 필수입니다")
    private OrderStatus status;

    public OrderStatusUpdateDto() {
    }

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }
}
