package com.example.project.parcial.repositories;

import com.example.project.parcial.models.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    // Custom query methods
    List<Product> findByNameContaining(String name);
    List<Product> findByPriceLessThanEqual(Double price);
    List<Product> findByStockGreaterThan(Integer stock);
}