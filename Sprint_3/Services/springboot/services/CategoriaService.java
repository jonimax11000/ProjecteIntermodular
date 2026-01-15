package com.pi.springboot.services;

import com.pi.springboot.DTO.CategoriaDTO;
import com.pi.springboot.model.Categoria;
import java.util.List;

public interface CategoriaService {
    List<CategoriaDTO> getAllCategories();

    CategoriaDTO getCategoriaById(Long id);

    Categoria getCategoriaEntityById(Long id);

    void saveCategoria(CategoriaDTO categoriaDTO);

    void deleteCategoria(Long id);
}
