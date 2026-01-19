package com.pi.springboot.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.pi.springboot.model.Video;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface VideoRepository extends JpaRepository<Video, Long> {
    @Query(value = "SELECT R FROM Video R WHERE R.titol LIKE CONCAT('%', :nom, '%')")
    List<Video> findByNom(@Param("nom") String nom);
}