package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.NivellDTO;
import com.pi.springboot.services.NivellService;

@Controller
public class NivellController {
    @Autowired
    private NivellService nivellService;

    @GetMapping("/api/nivells")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<NivellDTO> getNivells() {
        List<NivellDTO> nivells = nivellService.getAllNivells();
        return nivells;
    }

    @GetMapping("/api/nivells/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public NivellDTO getNivellById(@PathVariable Long id) {
        NivellDTO nivell = nivellService.getNivellById(id);
        return nivell;
    }

    @PostMapping("/nivells")
    public ResponseEntity<NivellDTO> addNivell(@RequestBody NivellDTO newNivell) {
        try {
            nivellService.saveNivell(newNivell);
            return new ResponseEntity<>(newNivell, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
