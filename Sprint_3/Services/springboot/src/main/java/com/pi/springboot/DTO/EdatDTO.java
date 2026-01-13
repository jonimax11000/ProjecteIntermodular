package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;

import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Video;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class EdatDTO {

	private Long id;
	private Integer edat;
	private Set<Long> videos;

	public static EdatDTO convertToDTO(Edat edat) {
		if (edat == null)
			return null;

		EdatDTO edatDTO = new EdatDTO();
		edatDTO.setId(edat.getId());
		edatDTO.setEdat(edat.getEdat());
		Set<Long> videosIds = new HashSet<>();
		for (Video video : edat.getVideos()) {
			videosIds.add(video.getId());
		}
		edatDTO.setVideos(videosIds);
		return edatDTO;
	}

	public static Edat convertToEntity(EdatDTO edatDTO, Set<Video> videos) {
		if (edatDTO == null)
			return null;

		Edat edat = new Edat();
		edat.setId(edatDTO.getId());
		edat.setEdat(edatDTO.getEdat());
		edat.setVideos(videos);

		return edat;
	}
}