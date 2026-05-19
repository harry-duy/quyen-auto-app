package com.quyenauto.product.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.product.dto.*;
import com.quyenauto.product.entity.Product;
import com.quyenauto.product.entity.ProductCategory;
import com.quyenauto.product.entity.ProductImage;
import com.quyenauto.product.repository.ProductCategoryRepository;
import com.quyenauto.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductCategoryRepository categoryRepository;

    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findByIsActiveTrueOrderBySortOrderAsc()
                .stream().map(CategoryResponse::from).toList();
    }

    public Page<ProductResponse> getProducts(Long categoryId, String keyword, Pageable pageable) {
        Page<Product> page;
        if (keyword != null && !keyword.isBlank()) {
            page = productRepository.search(keyword, pageable);
        } else if (categoryId != null) {
            page = productRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable);
        } else {
            page = productRepository.findByIsActiveTrue(pageable);
        }
        return page.map(ProductResponse::from);
    }

    public ProductResponse getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));
        return ProductResponse.from(product);
    }

    @Transactional
    public ProductResponse createProduct(CreateProductRequest request) {
        ProductCategory category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy danh mục"));

        Product product = Product.builder()
                .category(category)
                .name(request.getName())
                .description(request.getDescription())
                .specifications(request.getSpecifications())
                .basePrice(request.getBasePrice())
                .isActive(true)
                .build();

        if (request.getImageUrls() != null) {
            for (int i = 0; i < request.getImageUrls().size(); i++) {
                ProductImage img = ProductImage.builder()
                        .product(product)
                        .imageUrl(request.getImageUrls().get(i))
                        .sortOrder(i)
                        .build();
                product.getImages().add(img);
            }
        }

        return ProductResponse.from(productRepository.save(product));
    }

    @Transactional
    public ProductResponse updateProduct(Long id, CreateProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));

        if (request.getCategoryId() != null) {
            ProductCategory category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy danh mục"));
            product.setCategory(category);
        }

        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setSpecifications(request.getSpecifications());
        product.setBasePrice(request.getBasePrice());

        if (request.getImageUrls() != null) {
            product.getImages().clear();
            for (int i = 0; i < request.getImageUrls().size(); i++) {
                ProductImage img = ProductImage.builder()
                        .product(product)
                        .imageUrl(request.getImageUrls().get(i))
                        .sortOrder(i)
                        .build();
                product.getImages().add(img);
            }
        }

        return ProductResponse.from(productRepository.save(product));
    }

    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));
        product.setIsActive(false);
        productRepository.save(product);
    }
}
