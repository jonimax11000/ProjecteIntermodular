package com.pi.springboot.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.pi.springboot.models.Video;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface videorepository extends JpaRepository<Video, Long> {
}