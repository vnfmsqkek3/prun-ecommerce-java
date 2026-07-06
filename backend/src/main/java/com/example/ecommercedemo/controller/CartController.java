package com.example.ecommercedemo.controller;

import com.example.ecommercedemo.dto.CartDto;
import com.example.ecommercedemo.dto.CartItemAddDto;
import com.example.ecommercedemo.dto.CartItemUpdateDto;
import com.example.ecommercedemo.service.CartService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/carts")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @PostMapping("/items")
    public ResponseEntity<CartDto> addCartItem(
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody CartItemAddDto dto) {
        CartDto cart = cartService.addCartItem(userId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(cart);
    }

    @GetMapping
    public ResponseEntity<CartDto> selectCart(@RequestHeader("X-User-Id") Long userId) {
        CartDto cart = cartService.selectCart(userId);
        return ResponseEntity.ok(cart);
    }

    @PutMapping("/items/{cartItemId}")
    public ResponseEntity<CartDto> updateCartItemQuantity(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long cartItemId,
            @Valid @RequestBody CartItemUpdateDto dto) {
        CartDto cart = cartService.updateCartItemQuantity(userId, cartItemId, dto);
        return ResponseEntity.ok(cart);
    }

    @DeleteMapping("/items/{cartItemId}")
    public ResponseEntity<Void> deleteCartItem(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long cartItemId) {
        cartService.deleteCartItem(userId, cartItemId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clearCart(@RequestHeader("X-User-Id") Long userId) {
        cartService.clearCart(userId);
        return ResponseEntity.noContent().build();
    }
}
