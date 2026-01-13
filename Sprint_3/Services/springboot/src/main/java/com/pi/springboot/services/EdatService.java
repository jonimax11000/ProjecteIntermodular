package com.pi.springboot.services;

import com.pi.springboot.DTO.EdatDTO;
import java.util.List;

public interface EdatService {
    List<EdatDTO> getAllEdats();

    EdatDTO getEdatById(Long id);
}
