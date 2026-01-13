package com.pi.springboot.services;

import com.pi.springboot.DTO.NivellDTO;
import java.util.List;

public interface NivellService {
    List<NivellDTO> getAllNivells();

    NivellDTO getNivellById(Long id);
}
