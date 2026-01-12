package com.pi.springboot.model;

import java.io.Serializable;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@Entity
@Table
@ToString(exclude = { "serie", "edat", "categoria" })
public class Video implements Serializable {

	static final long serialVersionUID = 137L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@Column(nullable = false)
	private String titol;

	@Column(name = "url", nullable = false)
	private String videoURL;

	@Column(name = "thumbnail", nullable = false)
	private String thumbnailURL;

	@Column(nullable = false)
	private Integer duracio;

	@ManyToOne(cascade = CascadeType.PERSIST)
	@JoinColumn(name = "id", foreignKey = @ForeignKey(name = "FK_VID_SER"))
	private Serie serie;

	@ManyToOne(cascade = CascadeType.PERSIST)
	@JoinColumn(name = "id", foreignKey = @ForeignKey(name = "FK_VID_EDAT"))
	private Edat edat;

	@ManyToOne(cascade = CascadeType.PERSIST)
	@JoinColumn(name = "id", foreignKey = @ForeignKey(name = "FK_VID_CAT"))
	private Categoria categoria;
}
