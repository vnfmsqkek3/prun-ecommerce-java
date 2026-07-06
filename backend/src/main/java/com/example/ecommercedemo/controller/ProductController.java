package com.example.ecommercedemo.controller;

import com.example.ecommercedemo.dto.ProductCreateDto;
import com.example.ecommercedemo.dto.ProductDto;
import com.example.ecommercedemo.dto.ProductUpdateDto;
import com.example.ecommercedemo.entity.ProductCategory;
import com.example.ecommercedemo.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @PostMapping
    public ResponseEntity<ProductDto> insertProduct(@Valid @RequestBody ProductCreateDto dto) {
        ProductDto product = productService.insertProduct(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(product);
    }

    @GetMapping
    public ResponseEntity<Page<ProductDto>> selectProductList(
            @RequestParam(required = false) ProductCategory category,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        
        Page<ProductDto> products = category != null
                ? productService.selectProductListByCategory(category, pageable)
                : productService.selectProductList(pageable);
        
        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductDto> selectProduct(@PathVariable Long id) {
        ProductDto product = productService.selectProduct(id);
        return ResponseEntity.ok(product);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductDto> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody ProductUpdateDto dto) {
        ProductDto product = productService.updateProduct(id, dto);
        return ResponseEntity.ok(product);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }
}
