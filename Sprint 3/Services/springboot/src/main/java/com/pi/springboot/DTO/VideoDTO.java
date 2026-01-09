package com.pi.springboot.DTO;

import java.io.Serializable;

import com.pi.springboot.models.Video;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class VideoDTO implements Serializable {
    static final long serialVersionUID = 137L;
    
    private long id;
    private String titol;
    private String videoURL;
    private String thumbnailURL;
    private int duracio;
    
    public static VideoDTO convertToDTO(Video video) {
        VideoDTO videoDTO = new VideoDTO();
        videoDTO.setId(video.getId());
        videoDTO.setTitol(video.getTitol());
        videoDTO.setVideoURL(video.getVideoURL());
        videoDTO.setThumbnailURL(video.getThumbnailURL());
        videoDTO.setDuracio(video.getDuracio());
        
        return videoDTO;
    }
    
    public static Video convertToEntity(VideoDTO videoDTO) {
        Video video = new Video();
        video.setId(videoDTO.getId());
        video.setTitol(videoDTO.getTitol());
        video.setVideoURL(videoDTO.getVideoURL());
        video.setThumbnailURL(videoDTO.getThumbnailURL());
        video.setDuracio(videoDTO.getDuracio());
        
        return video;
    }
}