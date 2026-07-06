package com.example.ecommercedemo.repository;

import com.example.ecommercedemo.entity.Product;
import com.example.ecommercedemo.entity.ProductCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {
    
    boolean existsByName(String name);
    
    boolean existsByNameAndIdNot(String name, Long id);
    
    Page<Product> findByDeletedFalse(Pageable pageable);
    
    Page<Product> findByDeletedFalseAndCategory(ProductCategory category, Pageable pageable);
}
