package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
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

    @PostMapping("/api/cataleg")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public ResponseEntity<VideoDTO> addVideo(@RequestBody VideoDTO newVideo) {
        try {
            videoService.saveVideo(newVideo);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/api/videos/{id}")
    public ResponseEntity<String> deleteCliente(@PathVariable Long id) {
        videoService.deleteVideo(id);
        return new ResponseEntity<>("Cliente borrado satisfactoriamente", HttpStatus.OK);
    }
}
