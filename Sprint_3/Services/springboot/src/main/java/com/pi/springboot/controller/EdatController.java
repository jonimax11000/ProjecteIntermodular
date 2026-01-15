package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/api/edats")
    public ResponseEntity<EdatDTO> addEdat(@RequestBody EdatDTO newEdat) {
        try {
            edatService.saveEdat(newEdat);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/api/edats/{id}")
    public ResponseEntity<String> deleteEdat(@PathVariable Long id) {
        edatService.deleteEdat(id);
        return new ResponseEntity<>("Edat borrada satisfactoriamente", HttpStatus.OK);
    }
}
