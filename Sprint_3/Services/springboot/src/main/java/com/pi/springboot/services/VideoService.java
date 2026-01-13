package com.pi.springboot.services;

import com.pi.springboot.DTO.VideoDTO;
import java.util.List;

public interface VideoService {
    List<VideoDTO> getAllVideos();

    VideoDTO getVideoById(Long id);
}
