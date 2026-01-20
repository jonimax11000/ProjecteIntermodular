package com.pi.springboot.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Video;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface EdatRepository extends JpaRepository<Edat, Long> {
    boolean existsByEdat(Integer edat);
}