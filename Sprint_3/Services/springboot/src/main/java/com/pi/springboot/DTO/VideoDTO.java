package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Serie;
import com.pi.springboot.model.Video;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class VideoDTO {

	private Long id;
	private String titol;
	private String videoURL;
	private String thumbnailURL;
	private Integer duracio;

	public static VideoDTO convertToDTO(Video video) {
		if (video == null)
			return null;

		VideoDTO videoDTO = new VideoDTO();
		videoDTO.setId(video.getId());
		videoDTO.setTitol(video.getTitol());
		videoDTO.setVideoURL(video.getVideoURL());
		videoDTO.setThumbnailURL(video.getThumbnailURL());
		videoDTO.setDuracio(video.getDuracio());

		return videoDTO;
	}

	public static Video convertToEntity(VideoDTO videoDTO) {
		if (videoDTO == null)
			return null;

		Video video = new Video();
		video.setId(videoDTO.getId());
		video.setTitol(videoDTO.getTitol());

		video.setVideoURL(videoDTO.getVideoURL());
		video.setThumbnailURL(videoDTO.getThumbnailURL());

		video.setDuracio(videoDTO.getDuracio());

		return video;
	}
}