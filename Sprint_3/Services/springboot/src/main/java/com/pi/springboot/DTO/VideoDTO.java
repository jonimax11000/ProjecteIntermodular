package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;

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
	private Long serie;
	private Long edat;
	private Set<Long> categories = new HashSet<>();

	public static VideoDTO convertToDTO(Video video) {
		if (video == null)
			return null;

		VideoDTO videoDTO = new VideoDTO();
		videoDTO.setId(video.getId());
		videoDTO.setTitol(video.getTitol());
		videoDTO.setVideoURL(video.getVideoURL());
		videoDTO.setThumbnailURL(video.getThumbnailURL());
		videoDTO.setDuracio(video.getDuracio());
		if (video.getSerie() != null) {
			videoDTO.setSerie(video.getSerie().getId());
		} else {
			videoDTO.setSerie(null);
		}
		if (video.getEdat() != null) {
			videoDTO.setEdat(video.getEdat().getId());
		} else {
			videoDTO.setEdat(null);
		}
		Set<Categoria> categoriesFisiques = video.getCategories();
		Set<Long> categoriesIds = new HashSet<>();
		if (categoriesFisiques != null) {
			for (Categoria categoria : categoriesFisiques) {
				categoriesIds.add(categoria.getId());
			}
		}
		videoDTO.setCategories(categoriesIds);

		return videoDTO;
	}

	public static Video convertToEntity(VideoDTO videoDTO, Serie serie, Edat edat, Set<Categoria> categories) {
		if (videoDTO == null)
			return null;

		Video video = new Video();
		video.setTitol(videoDTO.getTitol());

		video.setVideoURL(videoDTO.getVideoURL());
		video.setThumbnailURL(videoDTO.getThumbnailURL());
		video.setDuracio(videoDTO.getDuracio());

		if (serie != null) {
			video.setSerie(serie);
		} else {
			video.setSerie(null);
		}

		if (edat != null) {
			video.setEdat(edat);
		} else {
			video.setEdat(null);
		}

		if (categories != null) {
			video.setCategories(categories);
		} else {
			video.setCategories(new HashSet<>());
		}

		return video;
	}
}