package com.example.ecommercedemo.dto;

import com.example.ecommercedemo.entity.CartItem;
import com.example.ecommercedemo.entity.Product;

import java.math.BigDecimal;

public class CartItemDto {

    private Long id;
    private Long productId;
    private String productName;
    private BigDecimal price;
    private Integer quantity;

    public CartItemDto() {
    }

    public static CartItemDto from(CartItem cartItem, Product product) {
        CartItemDto dto = new CartItemDto();
        dto.id = cartItem.getId();
        dto.productId = cartItem.getProductId();
        dto.productName = product.getName();
        dto.price = product.getPrice();
        dto.quantity = cartItem.getQuantity();
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
