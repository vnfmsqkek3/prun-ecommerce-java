package com.example.ecommercedemo.service;

import com.example.ecommercedemo.dto.CartDto;
import com.example.ecommercedemo.dto.CartItemAddDto;
import com.example.ecommercedemo.dto.CartItemDto;
import com.example.ecommercedemo.dto.CartItemUpdateDto;
import com.example.ecommercedemo.entity.Cart;
import com.example.ecommercedemo.entity.CartItem;
import com.example.ecommercedemo.entity.Product;
import com.example.ecommercedemo.exception.BusinessException;
import com.example.ecommercedemo.exception.ErrorCode;
import com.example.ecommercedemo.repository.CartItemRepository;
import com.example.ecommercedemo.repository.CartRepository;
import com.example.ecommercedemo.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class CartService {

    private static final Logger log = LoggerFactory.getLogger(CartService.class);
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;

    public CartService(CartRepository cartRepository, CartItemRepository cartItemRepository, 
                      ProductRepository productRepository) {
        this.cartRepository = cartRepository;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
    }

    @Transactional
    public CartDto addCartItem(Long userId, CartItemAddDto dto) {
        log.info("장바구니 상품 추가 시작 - userId: {}, productId: {}, quantity: {}", 
                 userId, dto.getProductId(), dto.getQuantity());

        // 상품 존재 확인
        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

        if (product.getDeleted()) {
            throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
        }

        // 장바구니 조회 또는 생성
        Cart cart = cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Cart newCart = Cart.create(userId);
                    return cartRepository.save(newCart);
                });

        // 이미 있는 상품이면 수량 증가, 없으면 새로 추가
        CartItem cartItem = cartItemRepository.findByCartIdAndProductId(cart.getId(), dto.getProductId())
                .orElse(null);

        if (cartItem != null) {
            cartItem.increaseQuantity(dto.getQuantity());
            log.info("장바구니 상품 수량 증가 - cartItemId: {}, newQuantity: {}", 
                     cartItem.getId(), cartItem.getQuantity());
        } else {
            cartItem = CartItem.create(dto.getProductId(), dto.getQuantity());
            cart.addCartItem(cartItem);
            cartItemRepository.save(cartItem);
            log.info("장바구니 상품 추가 완료 - productId: {}", dto.getProductId());
        }

        return selectCart(userId);
    }

    public CartDto selectCart(Long userId) {
        log.info("장바구니 조회 - userId: {}", userId);

        Cart cart = cartRepository.findByUserIdWithItems(userId)
                .orElseGet(() -> {
                    Cart newCart = Cart.create(userId);
                    return cartRepository.save(newCart);
                });

        // CartItem과 Product 정보를 조합하여 CartItemDto 생성
        List<CartItemDto> items = cart.getCartItems().stream()
                .map(cartItem -> {
                    Product product = productRepository.findById(cartItem.getProductId())
                            .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));
                    return CartItemDto.from(cartItem, product);
                })
                .collect(Collectors.toList());

        return CartDto.from(cart, items);
    }

    @Transactional
    public CartDto updateCartItemQuantity(Long userId, Long cartItemId, CartItemUpdateDto dto) {
        log.info("장바구니 상품 수량 변경 - userId: {}, cartItemId: {}, quantity: {}", 
                 userId, cartItemId, dto.getQuantity());

        CartItem cartItem = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CART_ITEM_NOT_FOUND));

        cartItem.updateQuantity(dto.getQuantity());
        log.info("장바구니 상품 수량 변경 완료 - cartItemId: {}", cartItemId);

        return selectCart(userId);
    }

    @Transactional
    public void deleteCartItem(Long userId, Long cartItemId) {
        log.info("장바구니 상품 삭제 - userId: {}, cartItemId: {}", userId, cartItemId);

        CartItem cartItem = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new BusinessException(ErrorCode.CART_ITEM_NOT_FOUND));

        cartItemRepository.delete(cartItem);
        log.info("장바구니 상품 삭제 완료 - cartItemId: {}", cartItemId);
    }

    @Transactional
    public void clearCart(Long userId) {
        log.info("장바구니 비우기 - userId: {}", userId);

        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.EMPTY_CART));

        cartItemRepository.deleteByCartId(cart.getId());
        log.info("장바구니 비우기 완료 - userId: {}", userId);
    }
}
