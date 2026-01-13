package com.pi.springboot.services;

import com.pi.springboot.DTO.SerieDTO;
import com.pi.springboot.model.Serie;
import com.pi.springboot.repository.SerieRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class SerieServiceImpl implements SerieService {
    @Autowired
    private SerieRepository seriesrepository;

    @Override
    public List<SerieDTO> getAllSeries() {
        List<Serie> lista = seriesrepository.findAll();
        List<SerieDTO> listaResultado = new ArrayList<SerieDTO>();

        for (int i = 0; i < lista.size(); ++i) {
            listaResultado.add(SerieDTO.convertToDTO(lista.get(i)));
        }
        return listaResultado;
    }

    @Override
    public SerieDTO getSerieById(Long id) {
        Optional<Serie> serie = seriesrepository.findById(id);
        if (serie.isPresent()) {
            return SerieDTO.convertToDTO(serie.get());
        } else {
            return null;
        }
    }
}