package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.EdatDTO;
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

    @PostMapping("/api/nivells")
    public ResponseEntity<NivellDTO> addNivell(@RequestBody NivellDTO newNivell) {
        try {
            nivellService.saveNivell(newNivell);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/api/nivells")
    public ResponseEntity<NivellDTO> updateEdat(@RequestBody NivellDTO updNivellDTO) {
        // busquem si existeix prèviament
        try {
            NivellDTO elNivell = nivellService.getNivellById(updNivellDTO.getId());
            if (elNivell == null) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            } else {
                // com ja sabem que existeix, save actualitza
                nivellService.changeNivell(elNivell, updNivellDTO);
                return new ResponseEntity<>(updNivellDTO, HttpStatus.OK);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/api/nivells/{id}")
    public ResponseEntity<String> deleteNivell(@PathVariable Long id) {
        nivellService.deleteNivell(id);
        return new ResponseEntity<>("Nivell borrado satisfactoriamente", HttpStatus.OK);
    }
}
