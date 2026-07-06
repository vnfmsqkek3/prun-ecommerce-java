package com.example.ecommercedemo.entity;

public enum OrderStatus {
    PENDING("대기중"),
    CONFIRMED("확인됨"),
    CANCELLED("취소됨");

    private final String description;

    OrderStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
