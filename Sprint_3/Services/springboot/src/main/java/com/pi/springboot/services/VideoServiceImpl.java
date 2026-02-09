package com.pi.springboot.services;

import com.pi.springboot.DTO.SerieDTO;
import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Nivell;
import com.pi.springboot.model.Serie;
import com.pi.springboot.model.Video;
import com.pi.springboot.repository.VideoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public class VideoServiceImpl implements VideoService {
    @Autowired
    private VideoRepository videorepository;

    @Autowired
    @Lazy
    private SerieService serieService;

    @Autowired
    @Lazy
    private EdatService edatService;

    @Autowired
    @Lazy
    private NivellService nivellService;

    @Autowired
    @Lazy
    private CategoriaService categoriaService;

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

    @Override
    public Video getVideoEntityById(Long id) {
        Optional<Video> video = videorepository.findById(id);
        if (video.isPresent()) {
            return video.get();
        } else {
            return null;
        }
    }

    @Override
    public List<VideoDTO> getVideosByName(String name) {
        List<Video> lista = videorepository.findByNom(name);
        List<VideoDTO> listaResultado = new ArrayList<VideoDTO>();

        for (Video v : lista) {
            listaResultado.add(VideoDTO.convertToDTO(v));
        }
        return listaResultado;
    }

    @Override
    public List<VideoDTO> getVideosByCategoria(Long id) {
        List<Video> lista = videorepository.findByCategoria(id);
        List<VideoDTO> listaResultado = new ArrayList<VideoDTO>();

        for (Video v : lista) {
            listaResultado.add(VideoDTO.convertToDTO(v));
        }
        return listaResultado;
    }

    @Override
    public List<VideoDTO> getVideosByEdat(Long id) {
        List<Video> lista = videorepository.findByEdat(id);
        List<VideoDTO> listaResultado = new ArrayList<VideoDTO>();

        for (Video v : lista) {
            listaResultado.add(VideoDTO.convertToDTO(v));
        }
        return listaResultado;
    }

    @Override
    public List<VideoDTO> getVideosByNivell(Long id) {
        List<Video> lista = videorepository.findByNivell(id);
        List<VideoDTO> listaResultado = new ArrayList<VideoDTO>();

        for (Video v : lista) {
            listaResultado.add(VideoDTO.convertToDTO(v));
        }
        return listaResultado;
    }

    @Override
    public List<VideoDTO> getVideosBySerie(Long id) {
        List<Video> lista = videorepository.findBySerie(id);
        List<VideoDTO> listaResultado = new ArrayList<VideoDTO>();

        for (Video v : lista) {
            listaResultado.add(VideoDTO.convertToDTO(v));
        }
        return listaResultado;
    }

    @Override
    public void saveVideo(VideoDTO videoDTO) {
        Serie serie = null;
        Edat edat = null;
        Nivell nivell = null;
        Set<Categoria> categorias = new HashSet<>();

        if (videoDTO.getSerie() != null) {
            serie = serieService.getSerieEntityById(videoDTO.getSerie());
        }
        if (videoDTO.getEdat() != null) {
            edat = edatService.getEdatEntityById(videoDTO.getEdat());
        }
        if (videoDTO.getNivell() != null) {
            nivell = nivellService.getNivellEntityById(videoDTO.getNivell());
        }
        if (videoDTO.getCategories() != null) {
            categorias = new HashSet<>();
            for (Long categoriaId : videoDTO.getCategories()) {
                categorias.add(categoriaService.getCategoriaEntityById(categoriaId));
            }
        }
        if (videoDTO.getCategories() != null) {
            for (Long categoriaId : videoDTO.getCategories()) {
                categorias.add(categoriaService.getCategoriaEntityById(categoriaId));
            }
        }
        Video video = VideoDTO.convertToEntity(videoDTO, serie, edat, nivell, categorias);
        videorepository.save(video);
    }

    @Override
    public void changeVideo(VideoDTO elVideo, VideoDTO updVideo) {
        Serie serie = null;
        Edat edat = null;
        Nivell nivell = null;
        Set<Categoria> categorias = new HashSet<>();

        if (updVideo.getSerie() != null) {
            serie = serieService.getSerieEntityById(updVideo.getSerie());
        }
        if (updVideo.getEdat() != null) {
            edat = edatService.getEdatEntityById(updVideo.getEdat());
        }
        if (updVideo.getNivell() != null) {
            nivell = nivellService.getNivellEntityById(updVideo.getNivell());
        }
        if (updVideo.getCategories() != null) {
            categorias = new HashSet<>();
            for (Long categoriaId : updVideo.getCategories()) {
                categorias.add(categoriaService.getCategoriaEntityById(categoriaId));
            }
        }
        Video video = getVideoEntityById(elVideo.getId());

        video.setTitol(updVideo.getTitol());
        video.setVideoURL(updVideo.getVideoURL());
        video.setThumbnailURL(updVideo.getThumbnailURL());
        video.setDuracio(updVideo.getDuracio());

        if (video.getSerie() != null && !video.getSerie().equals(serie)) {
            video.getSerie().getVideos().remove(video);
        }
        video.setSerie(serie);
        if (serie != null && !serie.getVideos().contains(video)) {
            serie.getVideos().add(video);
        }

        if (video.getEdat() != null && !video.getEdat().equals(edat)) {
            video.getEdat().getVideos().remove(video);
        }
        video.setEdat(edat);
        if (edat != null && !edat.getVideos().contains(video)) {
            edat.getVideos().add(video);
        }

        if (video.getNivell() != null && !video.getNivell().equals(nivell)) {
            video.getNivell().getVideos().remove(video);
        }
        video.setNivell(nivell);
        if (nivell != null && !nivell.getVideos().contains(video)) {
            nivell.getVideos().add(video);
        }
        for (Categoria categoria : video.getCategories()) {
            categoria.getVideos().remove(video);
        }
        video.getCategories().clear();

        for (Categoria categoria : categorias) {
            video.getCategories().add(categoria);
            categoria.getVideos().add(video);
        }
        videorepository.save(video);

    }

    @Override
    public void deleteVideo(Long id) {
        videorepository.deleteById(id);
    }
}