package com.pi.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.VideoDTO;
import com.pi.springboot.services.Videoservice;

@Controller
public class videoController {
	@Autowired
    private Videoservice videoService;
	
	@GetMapping("/api/cataleg")
    @ResponseBody
    public List<VideoDTO> getCataleg() {
		myLog.info(context.getMethod() + " from " + context.getRemoteHost());
	    List<VideoDTO> videos=videoService.getAllVideos();
	    return videos;
    }
	
	@GetMapping("/api/cataleg/{id}")
    @ResponseBody
    public VideoDTO getCatalegById(@PathVariable Long id) {
		VideoDTO video=videoService.getVideoById(id);
	    return video;
    }
}
