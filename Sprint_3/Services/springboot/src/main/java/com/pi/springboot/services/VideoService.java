package com.pi.springboot.services;

import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.model.Video;
import java.util.List;

public interface VideoService {
    List<VideoDTO> getAllVideos();

    VideoDTO getVideoById(Long id);

    Video getVideoEntityById(Long id);

    List<VideoDTO> getVideosByCategoria(Long id);

    List<VideoDTO> getVideosByEdat(Long id);

    List<VideoDTO> getVideosByNivell(Long id);

    List<VideoDTO> getVideosBySerie(Long id);

    void saveVideo(VideoDTO videoDTO);

    void deleteVideo(Long id);

    List<VideoDTO> getVideosByName(String name);
}
