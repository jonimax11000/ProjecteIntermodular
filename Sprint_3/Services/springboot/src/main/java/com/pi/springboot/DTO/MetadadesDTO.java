package com.pi.springboot.DTO;

import java.sql.Date;
import java.util.HashSet;
import java.util.Set;

import com.pi.springboot.model.Categoria;
import com.pi.springboot.model.Edat;
import com.pi.springboot.model.Metadades;
import com.pi.springboot.model.Nivell;
import com.pi.springboot.model.Serie;
import com.pi.springboot.model.Video;

import jakarta.persistence.Column;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Getter
@Setter
public class MetadadesDTO {
    private int width;

    private int height;

    private int fps;

    private int bitrate;

    private String codec;

    private int fileSize;

    private Date createdAt;

    public static MetadadesDTO convertToDTO(Metadades metadades) {
        if (metadades == null)
            return null;

        MetadadesDTO metadadesDTO = new MetadadesDTO();
        metadadesDTO.setWidth(metadades.getWidth());
        metadadesDTO.setHeight(metadades.getHeight());
        metadadesDTO.setFps(metadades.getFps());
        metadadesDTO.setBitrate(metadades.getBitrate());
        metadadesDTO.setCodec(metadades.getCodec());
        metadadesDTO.setFileSize(metadades.getFileSize());
        metadadesDTO.setCreatedAt(metadades.getCreatedAt());
        return metadadesDTO;
    }

    public static Metadades convertToEntity(MetadadesDTO metadadesDTO, Video video) {
        if (metadadesDTO == null)
            return null;

        Metadades metadades = new Metadades();
        metadades.setWidth(metadadesDTO.getWidth());
        metadades.setHeight(metadadesDTO.getHeight());
        metadades.setFps(metadadesDTO.getFps());
        metadades.setBitrate(metadadesDTO.getBitrate());
        metadades.setCodec(metadadesDTO.getCodec());
        metadades.setFileSize(metadadesDTO.getFileSize());
        metadades.setCreatedAt(metadadesDTO.getCreatedAt());

        return metadades;
    }
}
