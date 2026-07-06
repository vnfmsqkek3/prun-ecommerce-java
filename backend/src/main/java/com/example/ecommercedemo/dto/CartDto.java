package com.example.ecommercedemo.dto;

import com.example.ecommercedemo.entity.Cart;

import java.time.LocalDateTime;
import java.util.List;

public class CartDto {

    private Long id;
    private Long userId;
    private List<CartItemDto> items;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public CartDto() {
    }

    public static CartDto from(Cart cart, List<CartItemDto> items) {
        CartDto dto = new CartDto();
        dto.id = cart.getId();
        dto.userId = cart.getUserId();
        dto.items = items;
        dto.createdAt = cart.getCreatedAt();
        dto.updatedAt = cart.getUpdatedAt();
        return dto;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public List<CartItemDto> getItems() {
        return items;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}
