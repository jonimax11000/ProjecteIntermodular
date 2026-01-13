package com.pi.springboot.services;

import com.pi.springboot.DTO.CategoriaDTO;
import java.util.List;

public interface CategoriaService {
    List<CategoriaDTO> getAllCategorias();

    CategoriaDTO getCategoriaById(Long id);
}
