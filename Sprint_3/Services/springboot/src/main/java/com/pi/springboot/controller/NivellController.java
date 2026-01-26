package com.pi.springboot.controller;

import java.nio.file.AccessDeniedException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pi.springboot.DTO.NivellDTO;
import com.pi.springboot.services.NivellService;

@Controller
public class NivellController {
    @Autowired
    private NivellService nivellService;

    @GetMapping("/api/nivells")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public List<NivellDTO> getNivells() {
        List<NivellDTO> nivells = nivellService.getAllNivells();
        return nivells;
    }

    @GetMapping("/api/nivells/{id}")
    @CrossOrigin(origins = "*")
    @ResponseBody
    public NivellDTO getNivellById(@PathVariable Long id) {
        NivellDTO nivell = nivellService.getNivellById(id);
        return nivell;
    }

    @PostMapping("/api/nivells")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<NivellDTO> addNivell(@RequestBody NivellDTO newNivell, @AuthenticationPrincipal Jwt jwt) {
        try {
            System.out.println("\n\n\nNivell: " + newNivell);
            System.out.println("JWT: " + jwt + "\n\n\n");
            nivellService.saveNivell(newNivell);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/api/nivells")
    @CrossOrigin(origins = "*")
    @PreAuthorize("#jwt.getClaimAsString('role') == 'admin'")
    public ResponseEntity<NivellDTO> updateEdat(@RequestBody NivellDTO updNivellDTO,
            @AuthenticationPrincipal Jwt jwt) {
        // busquem si existeix prèviament
        try {
            NivellDTO elNivell = nivellService.getNivellById(updNivellDTO.getId());
            if (elNivell == null) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            } else {
                // com ja sabem que existeix, save actualitza
                nivellService.changeNivell(elNivell, updNivellDTO);
                return new ResponseEntity<>(updNivellDTO, HttpStatus.OK);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/api/nivells/{id}")
    @CrossOrigin(origins = "*")
    public ResponseEntity<String> deleteNivell(@PathVariable Long id, @AuthenticationPrincipal Jwt jwt) {
        nivellService.deleteNivell(id);
        return new ResponseEntity<>("Nivell borrado satisfactoriamente", HttpStatus.OK);
    }
}
