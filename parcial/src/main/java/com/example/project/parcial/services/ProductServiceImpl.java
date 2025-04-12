package com.example.project.parcial.services;

import com.example.project.parcial.models.Product;
import com.example.project.parcial.repositories.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    public ProductServiceImpl(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Override
    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }

    @Override
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @Override
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    @Override
    public List<Product> getProductsByName(String name) {
        return productRepository.findByNameContaining(name);
    }

    @Override
    public List<Product> getProductsByMaxPrice(Double price) {
        return productRepository.findByPriceLessThanEqual(price);
    }

    @Override
    public List<Product> getProductsInStock(Integer minStock) {
        return productRepository.findByStockGreaterThan(minStock);
    }

    @Override
    public Product updateProduct(Long id, Product productDetails) {
        return productRepository.findById(id)
            .map(existingProduct -> {
                existingProduct.setName(productDetails.getName());
                existingProduct.setDescription(productDetails.getDescription());
                existingProduct.setPrice(productDetails.getPrice());
                existingProduct.setStock(productDetails.getStock());
                return productRepository.save(existingProduct);
            })
            .orElse(null);
    }

    @Override
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    @Override
    public boolean existsById(Long id) {
        return productRepository.existsById(id);
    }
}