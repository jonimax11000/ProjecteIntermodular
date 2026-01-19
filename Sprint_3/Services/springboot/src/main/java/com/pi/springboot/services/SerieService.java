package com.pi.springboot.services;

import com.pi.springboot.DTO.SerieDTO;
import com.pi.springboot.model.Serie;

import java.util.List;

public interface SerieService {
    List<SerieDTO> getAllSeries();

    SerieDTO getSerieById(Long id);

    Serie getSerieEntityById(Long id);

    SerieDTO getSeriesByVideo(Long id);

    void saveSerie(SerieDTO serieDTO);

    void deleteSerie(Long id);

    List<SerieDTO> getSeriesByName(String name);
}
