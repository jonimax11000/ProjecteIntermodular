package com.pi.springboot.DTO;

import java.util.HashSet;
import java.util.Set;

import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Video;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class CategoriaDTO {

	private Long id;
	private String categoria;
	private Set<Long> videos = new HashSet<>();

	public static CategoriaDTO convertToDTO(Categoria categoria) {
		if (categoria == null)
			return null;

		CategoriaDTO categoriaDTO = new CategoriaDTO();
		categoriaDTO.setId(categoria.getId());
		categoriaDTO.setCategoria(categoria.getCategoria());
		Set<Long> videosIds = new HashSet<>();
		if (categoria.getVideos() != null) {
			for (Video video : categoria.getVideos()) {
				videosIds.add(video.getId());
			}
		}
		categoriaDTO.setVideos(videosIds);
		return categoriaDTO;
	}

	public static Categoria convertToEntity(CategoriaDTO categoriaDTO, Set<Video> videos) {
		if (categoriaDTO == null)
			return null;

		Categoria categoria = new Categoria();
		categoria.setCategoria(categoriaDTO.getCategoria());
		if (videos != null) {
			categoria.setVideos(videos);
		} else {
			categoria.setVideos(new HashSet<>());
		}
		return categoria;
	}
}