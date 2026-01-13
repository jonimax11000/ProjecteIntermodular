package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.EdatDTO;
import com.pi.springboot.services.EdatService;

@Controller
public class EdatController {
    @Autowired
    private EdatService edatService;

    @GetMapping("/api/edats")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<EdatDTO> getEdats() {
        List<EdatDTO> edats = edatService.getAllEdats();
        return edats;
    }

    @GetMapping("/api/edats/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public EdatDTO getEdatById(@PathVariable Long id) {
        EdatDTO edat = edatService.getEdatById(id);
        return edat;
    }
}
