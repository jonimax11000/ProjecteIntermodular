package com.pi.springboot.services;

import com.pi.springboot.DTO.CategoriaDTO;
import com.pi.springboot.DTO.EdatDTO;
import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Video;
import com.pi.springboot.repository.CategoriaRepository;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public class CategoriaServiceImpl implements CategoriaService {
    @Autowired
    private CategoriaRepository categoriarepository;

    @Autowired
    @Lazy
    private VideoService videoService;

    @Override
    public List<CategoriaDTO> getAllCategories() {
        List<Categoria> lista = categoriarepository.findAll();
        List<CategoriaDTO> listaResultado = new ArrayList<CategoriaDTO>();

        for (int i = 0; i < lista.size(); ++i) {
            listaResultado.add(CategoriaDTO.convertToDTO(lista.get(i)));
        }
        return listaResultado;
    }

    @Override
    public CategoriaDTO getCategoriaById(Long id) {
        Optional<Categoria> categoria = categoriarepository.findById(id);
        if (categoria.isPresent()) {
            return CategoriaDTO.convertToDTO(categoria.get());
        } else {
            return null;
        }
    }

    @Override
    public Categoria getCategoriaEntityById(Long id) {
        Optional<Categoria> categoria = categoriarepository.findById(id);
        if (categoria.isPresent()) {
            return categoria.get();
        } else {
            return null;
        }
    }

    @Override
    public void saveCategoria(CategoriaDTO categoriaDTO) {
        Set<Video> videos = new HashSet<>();
        if (categoriaDTO.getVideos() != null) {
            for (Long videoId : categoriaDTO.getVideos()) {
                videos.add(videoService.getVideoEntityById(videoId));
            }
        }
        Categoria categoria = CategoriaDTO.convertToEntity(categoriaDTO, videos);
        categoriarepository.save(categoria);
    }

    @Override
    @Transactional
    public void changeCategoria(CategoriaDTO laCategoria, CategoriaDTO updCategoria) {
        Categoria categoria = categoriarepository.findById(laCategoria.getId())
                .orElseThrow(() -> new EntityNotFoundException("Categoria not found with id: " + laCategoria.getId()));

        if (!categoria.getCategoria().equals(updCategoria.getCategoria())
                && categoriarepository.existsByCategoria(updCategoria.getCategoria())) {
            throw new IllegalStateException("Categoria with value " + updCategoria.getCategoria() + " already exists.");
        }

        categoria.setCategoria(updCategoria.getCategoria());
        categoriarepository.save(categoria);
    }

    @Override
    public void deleteCategoria(Long id) {
        categoriarepository.deleteById(id);
    }
}