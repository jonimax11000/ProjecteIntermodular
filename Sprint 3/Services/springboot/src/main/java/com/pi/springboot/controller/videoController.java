package com.pi.springboot.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class videoController {
	@GetMapping("/api/cataleg")
    @ResponseBody
    public String getCataleg() {
        return "Pruebas de distincion";
    }
	
	@GetMapping("/api/cataleg/{id}")
    @ResponseBody
    public String getCatalegById(@PathVariable Integer id) {
        return "Pruebas de distincion  "+id;
    }
}
