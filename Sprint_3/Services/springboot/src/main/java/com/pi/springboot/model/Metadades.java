package com.pi.springboot.model;

import java.sql.Date;
import java.io.Serializable;

import jakarta.persistence.*;
import lombok.*;

@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
@ToString
public class Metadades implements Serializable {

    @Column(nullable = false)
    private int width;

    @Column(nullable = false)
    private int height;

    @Column(nullable = false)
    private int fps;

    @Column(nullable = false)
    private int bitrate;

    @Column(nullable = false)
    private String codec;

    @Column(nullable = false)
    private int fileSize;

    @Column(nullable = false)
    private Date createdAt;
}
