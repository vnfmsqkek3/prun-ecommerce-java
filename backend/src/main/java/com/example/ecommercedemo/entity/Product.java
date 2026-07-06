package com.example.ecommercedemo.entity;

import com.example.ecommercedemo.exception.BusinessException;
import com.example.ecommercedemo.exception.ErrorCode;
import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "products")
public class Product extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer stockQuantity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private ProductCategory category;

    @Column(length = 500)
    private String imageUrl;

    @Column(nullable = false)
    private Boolean deleted = false;

    protected Product() {
    }

    private Product(String name, String description, BigDecimal price, Integer stockQuantity, 
                   ProductCategory category, String imageUrl) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.category = category;
        this.imageUrl = imageUrl;
        this.deleted = false;
    }

    public static Product create(String name, String description, BigDecimal price, 
                                Integer stockQuantity, ProductCategory category, String imageUrl) {
        return new Product(name, description, price, stockQuantity, category, imageUrl);
    }

    public void decreaseStock(int quantity) {
        if (this.stockQuantity < quantity) {
            throw new BusinessException(ErrorCode.INSUFFICIENT_STOCK);
        }
        this.stockQuantity -= quantity;
    }

    public void increaseStock(int quantity) {
        this.stockQuantity += quantity;
    }

    public void updateInfo(String name, String description, BigDecimal price, 
                          Integer stockQuantity, ProductCategory category, String imageUrl) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.category = category;
        this.imageUrl = imageUrl;
    }

    public void delete() {
        this.deleted = true;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public Integer getStockQuantity() {
        return stockQuantity;
    }

    public ProductCategory getCategory() {
        return category;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public Boolean getDeleted() {
        return deleted;
    }
}
