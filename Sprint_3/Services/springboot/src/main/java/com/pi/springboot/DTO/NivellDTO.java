package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;

import com.pi.springboot.model.Nivell;
import com.pi.springboot.model.Video;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class NivellDTO {

	private Long id;
	private Integer nivell;
	private Set<Long> videos;

	public static NivellDTO convertToDTO(Nivell nivell) {
		if (nivell == null)
			return null;

		NivellDTO nivellDTO = new NivellDTO();
		nivellDTO.setId(nivell.getId());
		nivellDTO.setNivell(nivell.getNivell());
		Set<Long> videosIds = new HashSet<>();
		if (nivell.getVideos() != null) {
			for (Video video : nivell.getVideos()) {
				videosIds.add(video.getId());
			}
		}
		nivellDTO.setVideos(videosIds);
		return nivellDTO;
	}

	public static Nivell convertToEntity(NivellDTO nivellDTO, Set<Video> videos) {
		if (nivellDTO == null)
			return null;

		Nivell nivell = new Nivell();
		nivell.setId(nivellDTO.getId());
		nivell.setNivell(nivellDTO.getNivell());
		if (videos != null) {
			nivell.setVideos(videos);
		} else {
			nivell.setVideos(new HashSet<>());
		}

		return nivell;
	}
}