package com.example.ecommercedemo.dto;

import com.example.ecommercedemo.entity.OrderItem;

import java.math.BigDecimal;

public class OrderItemDto {

    private Long id;
    private Long productId;
    private String productName;
    private BigDecimal price;
    private Integer quantity;

    public OrderItemDto() {
    }

    public static OrderItemDto from(OrderItem orderItem) {
        OrderItemDto dto = new OrderItemDto();
        dto.id = orderItem.getId();
        dto.productId = orderItem.getProductId();
        dto.productName = orderItem.getProductName();
        dto.price = orderItem.getPrice();
        dto.quantity = orderItem.getQuantity();
        return dto;
    }

    public Long getId() {
        return id;
    }

    public Long getProductId() {
        return productId;
    }

    public String getProductName() {
        return productName;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public Integer getQuantity() {
        return quantity;
    }
}
