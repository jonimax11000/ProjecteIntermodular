package com.pi.springboot.services;

import com.pi.springboot.DTO.CategoriaDTO;
import com.pi.springboot.model.Categoria;
import com.pi.springboot.repository.CategoriaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class CategoriaServiceImpl implements CategoriaService {
    @Autowired
    private CategoriaRepository categoriarepository;

    @Override
    public List<CategoriaDTO> getAllCategorias() {
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
}