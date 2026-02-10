package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
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

    @GetMapping("/api/seriesByName/{name}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<SerieDTO> getSeriesByName(@PathVariable String name) {
        List<SerieDTO> series = serieService.getSeriesByName(name);
        return series;
    }

    @GetMapping("/api/seriesByVideo/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public SerieDTO getSeriesByVideo(@PathVariable Long id) {
        SerieDTO serie = serieService.getSeriesByVideo(id);
        return serie;
    }

    @PostMapping("/api/series")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    @ResponseBody
    public ResponseEntity<?> addSerie(@RequestBody SerieDTO newSerie, @AuthenticationPrincipal Jwt jwt) {
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

    @PutMapping("api/series")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<SerieDTO> updEdat(@RequestBody SerieDTO updSerie, @AuthenticationPrincipal Jwt jwt) {
        try {
            SerieDTO laSerie = serieService.getSerieById(updSerie.getId());
            if (laSerie == null) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            } else {
                // com ja sabem que existeix, save actualitza
                serieService.changeSerie(laSerie, updSerie);
                return new ResponseEntity<>(updSerie, HttpStatus.OK);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/api/series/{id}")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<String> deleteSerie(@PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        serieService.deleteSerie(id);
        return new ResponseEntity<>("Serie borrada satisfactoriamente", HttpStatus.OK);
    }
}
