package com.pi.springboot.services;

import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.model.Video;
import com.pi.springboot.repository.VideoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class VideoServiceImpl implements VideoService {
    @Autowired
    private VideoRepository videorepository;

    @Override
    public List<VideoDTO> getAllVideos() {
        List<Video> lista = videorepository.findAll();
        List<VideoDTO> listaResultado = new ArrayList<VideoDTO>();

        for (int i = 0; i < lista.size(); ++i) {
            listaResultado.add(VideoDTO.convertToDTO(lista.get(i)));
        }
        return listaResultado;
    }

    @Override
    public VideoDTO getVideoById(Long id) {
        Optional<Video> video = videorepository.findById(id);
        if (video.isPresent()) {
            return VideoDTO.convertToDTO(video.get());
        } else {
            return null;
        }
    }
}