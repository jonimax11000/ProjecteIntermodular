package com.pi.springboot.model;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@Entity
@Table
@EqualsAndHashCode(exclude = { "videos" }) // Excluir la relación bidireccional
@ToString(exclude = { "videos" })
public class Categoria implements Serializable {

	static final long serialVersionUID = 137L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@Column(nullable = false, unique = true)
	private String categoria;

	@ManyToMany(mappedBy = "categories", cascade = CascadeType.PERSIST, fetch = FetchType.LAZY)
	@JsonBackReference
	private Set<Video> videos = new HashSet<>();
}
