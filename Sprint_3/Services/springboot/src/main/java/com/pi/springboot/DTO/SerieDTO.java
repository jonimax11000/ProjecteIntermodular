package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;

import com.pi.springboot.model.Serie;
import com.pi.springboot.model.Video;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class SerieDTO {

	private Long id;
	private String nom;
	private Integer temporada;
	private Set<Long> videos;

	public static SerieDTO convertToDTO(Serie serie) {
		if (serie == null)
			return null;

		SerieDTO serieDTO = new SerieDTO();
		serieDTO.setId(serie.getId());
		serieDTO.setNom(serie.getNom());
		serieDTO.setTemporada(serie.getTemporada());
		Set<Long> videosIds = new HashSet<>();
		if (serie.getVideos() != null) {
			for (Video video : serie.getVideos()) {
				videosIds.add(video.getId());
			}
		}
		serieDTO.setVideos(videosIds);
		return serieDTO;
	}

	public static Serie convertToEntity(SerieDTO serieDTO, Set<Video> videos) {
		if (serieDTO == null)
			return null;

		Serie serie = new Serie();
		serie.setId(serieDTO.getId());
		serie.setNom(serieDTO.getNom());
		serie.setTemporada(serieDTO.getTemporada());
		if (videos != null) {
			serie.setVideos(videos);
		} else {
			serie.setVideos(new HashSet<>());
		}

		return serie;
	}
}