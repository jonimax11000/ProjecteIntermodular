package com.pi.springboot.services;

import com.pi.springboot.DTO.EdatDTO;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Video;
import com.pi.springboot.repository.EdatRepository;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class EdatServiceImpl implements EdatService {
    @Autowired
    private EdatRepository edatrepository;

    @Autowired
    @Lazy
    private VideoService videoService;

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
        if (edatDTO.getVideos() != null) {
            for (Long videoId : edatDTO.getVideos()) {
                videos.add(videoService.getVideoEntityById(videoId));
            }
        }
        Edat edat = EdatDTO.convertToEntity(edatDTO, videos);
        edatrepository.save(edat);
    }

    @Override
    @Transactional
    public void changeEdat(EdatDTO laEdat, EdatDTO updEdat) {
        Edat edat = edatrepository.findById(laEdat.getId())
                .orElseThrow(() -> new EntityNotFoundException("Edat not found with id: " + laEdat.getId()));

        if (!edat.getEdat().equals(updEdat.getEdat()) && edatrepository.existsByEdat(updEdat.getEdat())) {
            throw new IllegalStateException("Edat with value " + updEdat.getEdat() + " already exists.");
        }

        edat.setEdat(updEdat.getEdat());
        edatrepository.save(edat);
    }

    @Override
    public void deleteEdat(Long id) {
        edatrepository.deleteById(id);
    }
}