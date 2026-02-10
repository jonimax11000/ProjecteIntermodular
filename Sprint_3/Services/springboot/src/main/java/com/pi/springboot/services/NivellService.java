package com.pi.springboot.services;

import com.pi.springboot.DTO.NivellDTO;
import com.pi.springboot.model.Nivell;

import java.util.List;

public interface NivellService {
    List<NivellDTO> getAllNivells();

    NivellDTO getNivellById(Long id);

    Nivell getNivellEntityById(Long id);

    void saveNivell(NivellDTO nivellDTO);

    void deleteNivell(Long id);

    void changeNivell(NivellDTO elNivell, NivellDTO updNivellDTO);
}
