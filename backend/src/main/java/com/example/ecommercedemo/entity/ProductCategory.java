package com.example.ecommercedemo.entity;

public enum ProductCategory {
    ELECTRONICS("전자제품"),
    CLOTHING("의류"),
    FOOD("식품"),
    BOOK("도서"),
    HOME("생활용품");

    private final String description;

    ProductCategory(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
