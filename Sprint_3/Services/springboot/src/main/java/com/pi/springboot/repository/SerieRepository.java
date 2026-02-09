package com.pi.springboot.repository;

import java.util.List;
import java.util.Optional;

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

    @Query(value = "SELECT R FROM Serie R JOIN R.videos V WHERE V.id = :id")
    Optional<Serie> findByVideo(@Param("id") Long id);

    @Query(value = "SELECT count(R)>0 FROM Serie R WHERE R.nom = :nom and R.temporada = :temporada")
    Boolean existsByNomAndTemporada(@Param("nom") String nom, @Param("temporada") Integer temporada);
}