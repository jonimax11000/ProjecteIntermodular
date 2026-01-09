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
    Optional<VideoDTO> getVideoById(Long id);
    
    /**
     * Crea un nuevo video
     * @param videoDTO DTO con los datos del video a crear
     * @return VideoDTO del video creado
     */
    VideoDTO createVideo(VideoDTO videoDTO);
    
    /**
     * Actualiza un video existente
     * @param id ID del video a actualizar
     * @param videoDTO DTO con los nuevos datos del video
     * @return VideoDTO del video actualizado
     */
    VideoDTO updateVideo(Long id, VideoDTO videoDTO);
    
    /**
     * Elimina un video por su ID
     * @param id ID del video a eliminar
     */
    void deleteVideo(Long id);
    
    /**
     * Verifica si existe un video con el ID proporcionado
     * @param id ID a verificar
     * @return true si existe, false si no
     */
    boolean existsById(Long id);
}
