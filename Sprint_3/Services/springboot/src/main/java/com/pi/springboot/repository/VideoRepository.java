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

    @Query(value = "SELECT R FROM Video R JOIN R.categories C WHERE C.id = :id")
    List<Video> findByCategoria(@Param("id") Long id);

    @Query(value = "SELECT R FROM Video R WHERE R.edat = (SELECT E FROM Edat E WHERE E.id = :id)")
    List<Video> findByEdat(@Param("id") Long id);

    @Query(value = "SELECT R FROM Video R WHERE R.nivell = (SELECT N FROM Nivell N WHERE N.id = :id)")
    List<Video> findByNivell(@Param("id") Long id);

    @Query(value = "SELECT R FROM Video R WHERE R.serie = (SELECT S FROM Serie S WHERE S.id = :id)")
    List<Video> findBySerie(@Param("id") Long id);
}