package com.pi.springboot.model;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@Entity
@Table
@ToString(exclude = { "serie", "edat", "categories", "nivell" })
@EqualsAndHashCode(exclude = { "serie", "edat", "categories", "nivell" })
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
	@JoinColumn(name = "serie", foreignKey = @ForeignKey(name = "FK_VID_SER"))
	private Serie serie;

	@ManyToOne(cascade = CascadeType.PERSIST)
	@JoinColumn(name = "edat", foreignKey = @ForeignKey(name = "FK_VID_EDAT"))
	private Edat edat;

	@ManyToOne(cascade = CascadeType.PERSIST)
	@JoinColumn(name = "nivell", foreignKey = @ForeignKey(name = "FK_VID_NIVELL"))
	private Nivell nivell;

	@ManyToMany(cascade = CascadeType.PERSIST)
	@JoinTable(name = "Vid_Cat", joinColumns = {
			@JoinColumn(name = "id_video", foreignKey = @ForeignKey(name = "FK_VID_CAT")) }, inverseJoinColumns = {
					@JoinColumn(name = "id_categoria", foreignKey = @ForeignKey(name = "FK_CAT_VID")) })
	private Set<Categoria> categories = new HashSet<>();
}
