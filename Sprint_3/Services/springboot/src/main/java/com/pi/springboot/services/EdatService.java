package com.pi.springboot.services;

import com.pi.springboot.DTO.EdatDTO;
import com.pi.springboot.model.Edat;
import java.util.List;

public interface EdatService {
    List<EdatDTO> getAllEdats();

    EdatDTO getEdatById(Long id);

    Edat getEdatEntityById(Long id);

    void saveEdat(EdatDTO edatDTO);

    void deleteEdat(Long id);

    void changeEdat(EdatDTO laEdat, EdatDTO updEdat);
}
