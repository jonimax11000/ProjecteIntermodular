package com.pi.springboot.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.pi.springboot.model.Serie;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface SerieRepository extends JpaRepository<Serie, Long> {
    @Query(value = "SELECT R FROM Serie R WHERE R.nom LIKE CONCAT('%', :nom, '%')")
    List<Serie> findByNom(@Param("nom") String nom);
}