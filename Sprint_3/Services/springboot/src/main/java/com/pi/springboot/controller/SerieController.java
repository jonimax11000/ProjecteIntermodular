package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.SerieDTO;
import com.pi.springboot.services.SerieService;

@Controller
public class SerieController {
    @Autowired
    private SerieService serieService;

    @GetMapping("/api/series")
    @ResponseBody
    public List<SerieDTO> getSeries() {
        List<SerieDTO> series = serieService.getAllSeries();
        return series;
    }

    @GetMapping("/api/series/{id}")
    @ResponseBody
    public SerieDTO getSerieById(@PathVariable Long id) {
        SerieDTO serie = serieService.getSerieById(id);
        return serie;
    }
}
