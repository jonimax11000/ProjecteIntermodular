package com.pi.springboot.services;

import com.pi.springboot.DTO.CategoriaDTO;
import java.util.List;

public interface CategoriaService {
    List<CategoriaDTO> getAllCategories();

    CategoriaDTO getCategoriaById(Long id);
}
