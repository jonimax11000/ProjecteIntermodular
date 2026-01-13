package com.pi.springboot.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.pi.springboot.model.Categoria;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface CategoriaRepository extends JpaRepository<Categoria, Long> {
}