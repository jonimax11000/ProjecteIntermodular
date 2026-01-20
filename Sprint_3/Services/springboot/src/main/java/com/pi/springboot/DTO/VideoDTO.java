package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;

import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Nivell;
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
	private String descripcio;
	private Integer duracio;
	private Long serie;
	private Long edat;
	private Long nivell;
	private Set<Long> categories = new HashSet<>();

	public static VideoDTO convertToDTO(Video video) {
		if (video == null)
			return null;

		VideoDTO videoDTO = new VideoDTO();
		videoDTO.setId(video.getId());
		videoDTO.setTitol(video.getTitol());
		videoDTO.setVideoURL(video.getVideoURL());
		videoDTO.setThumbnailURL(video.getThumbnailURL());
		videoDTO.setDescripcio(video.getDescripcio());
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
		if (video.getNivell() != null) {
			videoDTO.setNivell(video.getNivell().getId());
		} else {
			videoDTO.setNivell(null);
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

	public static Video convertToEntity(VideoDTO videoDTO, Serie serie, Edat edat, Nivell nivell,
			Set<Categoria> categories) {
		if (videoDTO == null)
			return null;

		Video video = new Video();
		video.setTitol(videoDTO.getTitol());

		video.setVideoURL(videoDTO.getVideoURL());
		video.setThumbnailURL(videoDTO.getThumbnailURL());
		video.setDuracio(videoDTO.getDuracio());
		video.setDescripcio(videoDTO.getDescripcio());

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

		if (nivell != null) {
			video.setNivell(nivell);
		} else {
			video.setNivell(null);
		}

		if (categories != null) {
			video.setCategories(categories);
		} else {
			video.setCategories(new HashSet<>());
		}

		return video;
	}
}