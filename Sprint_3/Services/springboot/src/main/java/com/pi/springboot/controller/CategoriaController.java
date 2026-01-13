package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.CategoriaDTO;
import com.pi.springboot.services.CategoriaService;

@Controller
public class CategoriaController {
    @Autowired
    private CategoriaService categoriaService;

    @GetMapping("/api/categories")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<CategoriaDTO> getCategories() {
        List<CategoriaDTO> categories = categoriaService.getAllCategories();
        return categories;
    }

    @GetMapping("/api/categories/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public CategoriaDTO getCategoryById(@PathVariable Long id) {
        CategoriaDTO categoria = categoriaService.getCategoriaById(id);
        return categoria;
    }
}
