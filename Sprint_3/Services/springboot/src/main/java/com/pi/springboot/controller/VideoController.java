package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.web.bind.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.services.VideoService;

@Controller
public class VideoController {
    @Autowired
    private VideoService videoService;

    @GetMapping("/api/cataleg")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<VideoDTO> getCataleg() {
        List<VideoDTO> videos = videoService.getAllVideos();
        return videos;
    }

    @GetMapping("/api/cataleg/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public VideoDTO getCatalegById(@PathVariable Long id) {
        VideoDTO video = videoService.getVideoById(id);
        return video;
    }

    @GetMapping("/api/catalegByName/{name}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<VideoDTO> getVideosByName(@PathVariable String name) {
        List<VideoDTO> videos = videoService.getVideosByName(name);
        return videos;
    }

    @GetMapping("/api/catalegByCategoria/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<VideoDTO> getVideosByCategoria(@PathVariable Long id) {
        List<VideoDTO> videos = videoService.getVideosByCategoria(id);
        return videos;
    }

    @GetMapping("/api/catalegByEdat/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<VideoDTO> getVideosByEdat(@PathVariable Long id) {
        List<VideoDTO> videos = videoService.getVideosByEdat(id);
        return videos;
    }

    @GetMapping("/api/catalegByNivell/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<VideoDTO> getVideosByNivell(@PathVariable Long id) {
        List<VideoDTO> videos = videoService.getVideosByNivell(id);
        return videos;
    }

    @GetMapping("/api/catalegBySerie/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<VideoDTO> getVideosBySerie(@PathVariable Long id) {
        List<VideoDTO> videos = videoService.getVideosBySerie(id);
        return videos;
    }

    @PostMapping("/api/cataleg")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    @ResponseBody
    public ResponseEntity<VideoDTO> addVideo(@RequestBody VideoDTO newVideo, @AuthenticationPrincipal Jwt jwt) {
        try {
            videoService.saveVideo(newVideo);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("api/cataleg")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<VideoDTO> updVideo(@RequestBody VideoDTO updVideo, @AuthenticationPrincipal Jwt jwt) {
        try {
            VideoDTO laVideo = videoService.getVideoById(updVideo.getId());
            if (laVideo == null) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            } else {
                // com ja sabem que existeix, save actualitza
                videoService.changeVideo(laVideo, updVideo);
                return new ResponseEntity<>(updVideo, HttpStatus.OK);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/api/cataleg/{id}")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<String> deleteVideo(@PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        videoService.deleteVideo(id);
        return new ResponseEntity<>("Video borrado satisfactoriamente", HttpStatus.OK);
    }
}
