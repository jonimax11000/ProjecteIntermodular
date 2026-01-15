package com.pi.springboot.services;

import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.model.Video;
import java.util.List;

public interface VideoService {
    List<VideoDTO> getAllVideos();

    VideoDTO getVideoById(Long id);

    Video getVideoEntityById(Long id);

    void saveVideo(VideoDTO videoDTO);
}
