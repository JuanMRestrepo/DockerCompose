package com.example.project.parcial.services;

import com.example.project.parcial.models.Product;  
import java.util.List;
import java.util.Optional;

public interface ProductService {
    
    // Create
    Product saveProduct(Product product);
    
    // Read
    List<Product> getAllProducts();
    Optional<Product> getProductById(Long id);
    List<Product> getProductsByName(String name);
    List<Product> getProductsByMaxPrice(Double price);
    List<Product> getProductsInStock(Integer minStock);
    
    // Update
    Product updateProduct(Long id, Product productDetails);
    
    // Delete
    void deleteProduct(Long id);
    
    // Check if exists
    boolean existsById(Long id);
}