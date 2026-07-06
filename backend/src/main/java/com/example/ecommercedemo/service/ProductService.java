package com.example.ecommercedemo.service;

import com.example.ecommercedemo.dto.ProductCreateDto;
import com.example.ecommercedemo.dto.ProductDto;
import com.example.ecommercedemo.dto.ProductUpdateDto;
import com.example.ecommercedemo.entity.Product;
import com.example.ecommercedemo.entity.ProductCategory;
import com.example.ecommercedemo.exception.BusinessException;
import com.example.ecommercedemo.exception.ErrorCode;
import com.example.ecommercedemo.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class ProductService {

    private static final Logger log = LoggerFactory.getLogger(ProductService.class);
    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Transactional
    public ProductDto insertProduct(ProductCreateDto dto) {
        log.info("상품 등록 시작 - name: {}", dto.getName());

        if (productRepository.existsByName(dto.getName())) {
            throw new BusinessException(ErrorCode.DUPLICATE_PRODUCT_NAME);
        }

        Product product = Product.create(
                dto.getName(),
                dto.getDescription(),
                dto.getPrice(),
                dto.getStockQuantity(),
                dto.getCategory(),
                dto.getImageUrl()
        );

        Product savedProduct = productRepository.save(product);
        log.info("상품 등록 완료 - id: {}, name: {}", savedProduct.getId(), savedProduct.getName());

        return ProductDto.from(savedProduct);
    }

    public Page<ProductDto> selectProductList(Pageable pageable) {
        log.info("상품 목록 조회 - page: {}, size: {}", pageable.getPageNumber(), pageable.getPageSize());
        
        Page<Product> products = productRepository.findByDeletedFalse(pageable);
        return products.map(ProductDto::from);
    }

    public Page<ProductDto> selectProductListByCategory(ProductCategory category, Pageable pageable) {
        log.info("카테고리별 상품 목록 조회 - category: {}, page: {}, size: {}", 
                 category, pageable.getPageNumber(), pageable.getPageSize());
        
        Page<Product> products = productRepository.findByDeletedFalseAndCategory(category, pageable);
        return products.map(ProductDto::from);
    }

    public ProductDto selectProduct(Long id) {
        log.info("상품 상세 조회 - id: {}", id);

        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

        if (product.getDeleted()) {
            throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
        }

        return ProductDto.from(product);
    }

    @Transactional
    public ProductDto updateProduct(Long id, ProductUpdateDto dto) {
        log.info("상품 수정 시작 - id: {}, name: {}", id, dto.getName());

        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

        if (product.getDeleted()) {
            throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
        }

        if (productRepository.existsByNameAndIdNot(dto.getName(), id)) {
            throw new BusinessException(ErrorCode.DUPLICATE_PRODUCT_NAME);
        }

        product.updateInfo(
                dto.getName(),
                dto.getDescription(),
                dto.getPrice(),
                dto.getStockQuantity(),
                dto.getCategory(),
                dto.getImageUrl()
        );

        log.info("상품 수정 완료 - id: {}", id);
        return ProductDto.from(product);
    }

    @Transactional
    public void deleteProduct(Long id) {
        log.info("상품 삭제 시작 - id: {}", id);

        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

        if (product.getDeleted()) {
            throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
        }

        product.delete();
        log.info("상품 삭제 완료 - id: {}", id);
    }
}
