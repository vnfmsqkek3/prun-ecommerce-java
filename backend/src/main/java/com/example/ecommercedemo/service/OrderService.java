package com.example.ecommercedemo.service;

import com.example.ecommercedemo.dto.*;
import com.example.ecommercedemo.entity.Order;
import com.example.ecommercedemo.entity.OrderItem;
import com.example.ecommercedemo.entity.OrderStatus;
import com.example.ecommercedemo.entity.Product;
import com.example.ecommercedemo.exception.BusinessException;
import com.example.ecommercedemo.exception.ErrorCode;
import com.example.ecommercedemo.repository.CartItemRepository;
import com.example.ecommercedemo.repository.CartRepository;
import com.example.ecommercedemo.repository.OrderRepository;
import com.example.ecommercedemo.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;

    public OrderService(OrderRepository orderRepository, ProductRepository productRepository,
                       CartRepository cartRepository, CartItemRepository cartItemRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.cartRepository = cartRepository;
        this.cartItemRepository = cartItemRepository;
    }

    @Transactional
    public OrderDto insertOrder(OrderCreateDto dto) {
        log.info("주문 생성 시작 - userId: {}, itemCount: {}", dto.getUserId(), dto.getItems().size());

        if (dto.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.EMPTY_ORDER_ITEMS);
        }

        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;

        // 1. 모든 상품 조회 및 재고 확인
        for (OrderItemCreateDto itemDto : dto.getItems()) {
            Product product = productRepository.findById(itemDto.getProductId())
                    .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

            if (product.getDeleted()) {
                throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
            }

            // 재고 확인 (재고 부족 시 상품명 포함하여 에러)
            if (product.getStockQuantity() < itemDto.getQuantity()) {
                throw new BusinessException(
                        ErrorCode.INSUFFICIENT_STOCK,
                        String.format("상품 '%s'의 재고가 부족합니다 (요청: %d, 재고: %d)",
                                product.getName(), itemDto.getQuantity(), product.getStockQuantity())
                );
            }

            // 2. 재고 차감
            product.decreaseStock(itemDto.getQuantity());

            // 3. OrderItem 생성 (주문 시점의 상품명, 가격 저장)
            OrderItem orderItem = OrderItem.create(
                    product.getId(),
                    product.getName(),
                    product.getPrice(),
                    itemDto.getQuantity()
            );
            orderItems.add(orderItem);

            // 4. 총액 계산
            BigDecimal itemTotal = product.getPrice().multiply(BigDecimal.valueOf(itemDto.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);
        }

        // 5. Order 생성
        Order order = Order.create(dto.getUserId(), totalAmount);
        for (OrderItem orderItem : orderItems) {
            order.addOrderItem(orderItem);
        }

        Order savedOrder = orderRepository.save(order);
        log.info("주문 생성 완료 - orderId: {}, totalAmount: {}", savedOrder.getId(), savedOrder.getTotalAmount());

        return OrderDto.from(savedOrder);
    }

    @Transactional
    public OrderDto insertOrderFromCart(Long userId) {
        log.info("장바구니 기반 주문 생성 시작 - userId: {}", userId);

        // 장바구니 조회
        var cart = cartRepository.findByUserIdWithItems(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.EMPTY_CART));

        if (cart.getCartItems().isEmpty()) {
            throw new BusinessException(ErrorCode.EMPTY_CART);
        }

        // 장바구니 내용을 OrderCreateDto로 변환
        OrderCreateDto orderCreateDto = new OrderCreateDto();
        orderCreateDto.setUserId(userId);
        
        List<OrderItemCreateDto> items = cart.getCartItems().stream()
                .map(cartItem -> {
                    OrderItemCreateDto itemDto = new OrderItemCreateDto();
                    itemDto.setProductId(cartItem.getProductId());
                    itemDto.setQuantity(cartItem.getQuantity());
                    return itemDto;
                })
                .collect(Collectors.toList());
        
        orderCreateDto.setItems(items);

        // 기존 주문 생성 로직 재사용
        OrderDto orderDto = insertOrder(orderCreateDto);

        // 주문 생성 성공 시 장바구니 비우기
        cart.clearItems();
        log.info("장바구니 기반 주문 생성 완료 - orderId: {}, 장바구니 비우기 완료", orderDto.getId());

        return orderDto;
    }

    public Page<OrderDto> selectOrderList(Long userId, Pageable pageable) {
        log.info("주문 목록 조회 - userId: {}, page: {}, size: {}", 
                 userId, pageable.getPageNumber(), pageable.getPageSize());
        
        Page<Order> orders = orderRepository.findByUserId(userId, pageable);
        return orders.map(OrderDto::from);
    }

    public Page<OrderDto> selectOrderListByStatus(Long userId, OrderStatus status, Pageable pageable) {
        log.info("주문 목록 조회 (상태 필터) - userId: {}, status: {}, page: {}, size: {}", 
                 userId, status, pageable.getPageNumber(), pageable.getPageSize());
        
        Page<Order> orders = orderRepository.findByUserIdAndStatus(userId, status, pageable);
        return orders.map(OrderDto::from);
    }

    public OrderDto selectOrder(Long id) {
        log.info("주문 상세 조회 - orderId: {}", id);

        Order order = orderRepository.findByIdWithItems(id);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        return OrderDto.from(order);
    }

    @Transactional
    public OrderDto updateOrderStatus(Long id, OrderStatusUpdateDto dto) {
        log.info("주문 상태 변경 시작 - orderId: {}, newStatus: {}", id, dto.getStatus());

        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ORDER_NOT_FOUND));

        order.updateStatus(dto.getStatus());
        log.info("주문 상태 변경 완료 - orderId: {}, status: {}", id, order.getStatus());

        return OrderDto.from(order);
    }

    @Transactional
    public OrderDto cancelOrder(Long id) {
        log.info("주문 취소 시작 - orderId: {}", id);

        Order order = orderRepository.findByIdWithItems(id);
        if (order == null) {
            throw new BusinessException(ErrorCode.ORDER_NOT_FOUND);
        }

        // 주문 취소 (PENDING 상태 확인은 Entity에서 처리)
        order.cancel();

        // 재고 복구
        for (OrderItem orderItem : order.getOrderItems()) {
            Product product = productRepository.findById(orderItem.getProductId())
                    .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));
            
            product.increaseStock(orderItem.getQuantity());
            log.debug("재고 복구 - productId: {}, quantity: {}", product.getId(), orderItem.getQuantity());
        }

        log.info("주문 취소 완료 - orderId: {}", id);
        return OrderDto.from(order);
    }
}
