package com.pi.springboot.services;

import com.pi.springboot.DTO.VideoDTO;
import java.util.List;
import java.util.Optional; 

public interface Videoservice {
	/**
     * Obtiene todos los videos
     * @return Lista de VideoDTO con todos los videos
     */
    List<VideoDTO> getAllVideos();
    
    /**
     * Obtiene un video por su ID
     * @param id ID del video a buscar
     * @return Optional con VideoDTO si existe, vacío si no
     */
    VideoDTO getVideoById(Long id);
}
