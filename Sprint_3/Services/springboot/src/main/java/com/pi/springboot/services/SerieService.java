package com.pi.springboot.services;

import com.pi.springboot.DTO.SerieDTO;
import java.util.List;

public interface SerieService {
    List<SerieDTO> getAllSeries();

    SerieDTO getSerieById(Long id);
}
