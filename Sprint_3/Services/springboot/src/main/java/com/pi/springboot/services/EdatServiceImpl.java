package com.pi.springboot.services;

import com.pi.springboot.DTO.EdatDTO;
import com.pi.springboot.model.Edat;
import com.pi.springboot.repository.EdatRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class EdatServiceImpl implements EdatService {
    @Autowired
    private EdatRepository edatrepository;

    @Override
    public List<EdatDTO> getAllEdats() {
        List<Edat> lista = edatrepository.findAll();
        List<EdatDTO> listaResultado = new ArrayList<EdatDTO>();

        for (int i = 0; i < lista.size(); ++i) {
            listaResultado.add(EdatDTO.convertToDTO(lista.get(i)));
        }
        return listaResultado;
    }

    @Override
    public EdatDTO getEdatById(Long id) {
        Optional<Edat> edat = edatrepository.findById(id);
        if (edat.isPresent()) {
            return EdatDTO.convertToDTO(edat.get());
        } else {
            return null;
        }
    }
}