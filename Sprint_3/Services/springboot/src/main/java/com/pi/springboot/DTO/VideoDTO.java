package com.pi.springboot.DTO;

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

		// IMPORTANTE: Usa los getters de Lombok
		// Lombok generó getUrl() y getThumbnail() por los nombres de columnas
		videoDTO.setVideoURL(video.getVideoURL()); // Cambia esto
		videoDTO.setThumbnailURL(video.getThumbnailURL()); // Cambia esto

		videoDTO.setDuracio(video.getDuracio());

		return videoDTO;
	}

	public static Video convertToEntity(VideoDTO videoDTO) {
		if (videoDTO == null)
			return null;

		Video video = new Video();
		video.setId(videoDTO.getId());
		video.setTitol(videoDTO.getTitol());

		// IMPORTANTE: Usa los setters de Lombok
		video.setVideoURL(videoDTO.getVideoURL()); // Cambia esto
		video.setThumbnailURL(videoDTO.getThumbnailURL()); // Cambia esto

		video.setDuracio(videoDTO.getDuracio());

		return video;
	}
}