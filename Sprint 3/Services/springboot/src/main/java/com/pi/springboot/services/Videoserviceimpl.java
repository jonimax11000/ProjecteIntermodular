package com.pi.springboot.services;

import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.models.Video;
import com.pi.springboot.repository.videorepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class Videoserviceimpl implements Videoservice {

    private final videorepository videorepository;

    @Autowired
    public Videoserviceimpl(videorepository videorepository) {
        this.videorepository = videorepository;
    }

    @Override
    public List<VideoDTO> getAllVideos() {
        return videorepository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public Optional<VideoDTO> getVideoById(Long id) {
        return videorepository.findById(id)
                .map(this::convertToDTO);
    }

    @Override
    public VideoDTO createVideo(VideoDTO videoDTO) {
        // Si el ID es autogenerado, no deberíamos recibirlo en el DTO para creación
        Video video = convertToEntity(videoDTO);
        video.setId(0); // Asegurar que sea nuevo (0 o null dependiendo de la estrategia)
        
        Video savedVideo = videorepository.save(video);
        return convertToDTO(savedVideo);
    }

    @Override
    public VideoDTO updateVideo(Long id, VideoDTO videoDTO) {
        // Verificar que el video existe
        if (!videorepository.existsById(id)) {
            throw new RuntimeException("Video no encontrado con id: " + id);
        }
        
        // Asegurar que el ID del DTO coincida con el parámetro
        videoDTO.setId(id);
        Video video = convertToEntity(videoDTO);
        
        Video updatedVideo = videorepository.save(video);
        return convertToDTO(updatedVideo);
    }

    @Override
    public void deleteVideo(Long id) {
        if (!videorepository.existsById(id)) {
            throw new RuntimeException("Video no encontrado con id: " + id);
        }
        videorepository.deleteById(id);
    }

    @Override
    public boolean existsById(Long id) {
        return videorepository.existsById(id);
    }

    // Métodos auxiliares de conversión
    
    private VideoDTO convertToDTO(Video video) {
        if (video == null) {
            return null;
        }
        
        return VideoDTO.convertToDTO(video);
    }
    
    private Video convertToEntity(VideoDTO videoDTO) {
        if (videoDTO == null) {
            return null;
        }
        
        return VideoDTO.convertToEntity(videoDTO);
    }
}