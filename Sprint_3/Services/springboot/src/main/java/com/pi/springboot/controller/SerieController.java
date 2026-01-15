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

import com.pi.springboot.DTO.SerieDTO;
import com.pi.springboot.services.SerieService;

@Controller
public class SerieController {
    @Autowired
    private SerieService serieService;

    @GetMapping("/api/series")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<SerieDTO> getSeries() {
        List<SerieDTO> series = serieService.getAllSeries();
        return series;
    }

    @GetMapping("/api/series/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public SerieDTO getSerieById(@PathVariable Long id) {
        SerieDTO serie = serieService.getSerieById(id);
        return serie;
    }

    @PostMapping("/api/series")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public ResponseEntity<?> addSerie(@RequestBody SerieDTO newSerie) {
        System.out.println("=== RECIBIENDO SERIE ===");
        System.out.println("Nombre: " + newSerie.getNom());
        System.out.println("Temporada: " + newSerie.getTemporada());
        System.out.println("Videos: " + (newSerie.getVideos() != null ? newSerie.getVideos().size() : "null"));

        try {
            serieService.saveSerie(newSerie);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
