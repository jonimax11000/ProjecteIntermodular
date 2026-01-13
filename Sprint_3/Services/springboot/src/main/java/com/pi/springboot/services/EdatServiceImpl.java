package com.pi.springboot.services;

import com.pi.springboot.DTO.EdatDTO;
import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Video;
import com.pi.springboot.repository.EdatRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public class EdatServiceImpl implements EdatService {
    @Autowired
    private EdatRepository edatrepository;

    @Autowired
    private VideoServiceImpl videoService;

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

    @Override
    public Edat getEdatEntityById(Long id) {
        Optional<Edat> edat = edatrepository.findById(id);
        if (edat.isPresent()) {
            return edat.get();
        } else {
            return null;
        }
    }

    @Override
    public void saveEdat(EdatDTO edatDTO) {
        Set<Video> videos = new HashSet<>();
        for (Long videoId : edatDTO.getVideos()) {
            videos.add(videoService.getVideoEntityById(videoId));
        }
        Edat edat = EdatDTO.convertToEntity(edatDTO, videos);
        edatrepository.save(edat);
    }
}