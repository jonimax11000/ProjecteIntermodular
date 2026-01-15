package com.pi.springboot.services;

import com.pi.springboot.DTO.NivellDTO;
import com.pi.springboot.model.Nivell;
import com.pi.springboot.model.Video;
import com.pi.springboot.repository.NivellRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public class NivellServiceImpl implements NivellService {
    @Autowired
    private NivellRepository nivellrepository;

    @Autowired
    @Lazy
    private VideoService videoService;

    @Override
    public List<NivellDTO> getAllNivells() {
        List<Nivell> lista = nivellrepository.findAll();
        List<NivellDTO> listaResultado = new ArrayList<NivellDTO>();

        for (int i = 0; i < lista.size(); ++i) {
            listaResultado.add(NivellDTO.convertToDTO(lista.get(i)));
        }
        return listaResultado;
    }

    @Override
    public NivellDTO getNivellById(Long id) {
        Optional<Nivell> nivell = nivellrepository.findById(id);
        if (nivell.isPresent()) {
            return NivellDTO.convertToDTO(nivell.get());
        } else {
            return null;
        }
    }

    @Override
    public Nivell getNivellEntityById(Long id) {
        Optional<Nivell> nivell = nivellrepository.findById(id);
        if (nivell.isPresent()) {
            return nivell.get();
        } else {
            return null;
        }
    }

    @Override
    public void saveNivell(NivellDTO nivellDTO) {
        Set<Video> videos = new HashSet<>();
        if (nivellDTO.getVideos() != null) {
            for (Long videoId : nivellDTO.getVideos()) {
                videos.add(videoService.getVideoEntityById(videoId));
            }
        }
        Nivell nivell = NivellDTO.convertToEntity(nivellDTO, videos);
        nivellrepository.save(nivell);
    }

    @Override
    public void deleteNivell(Long id) {
        nivellrepository.deleteById(id);
    }
}