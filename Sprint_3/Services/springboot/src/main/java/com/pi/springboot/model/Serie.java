package com.pi.springboot.model;

import java.io.Serializable;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@Entity
@Table
@ToString(exclude = { "videos" })
@EqualsAndHashCode(exclude = { "videos" })
public class Serie implements Serializable {

	static final long serialVersionUID = 137L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@Column(nullable = false)
	private String nom;

	@Column(nullable = false)
	private Integer temporada;

	@OneToMany(mappedBy = "serie", cascade = CascadeType.PERSIST, fetch = FetchType.LAZY)
	@JsonBackReference
	private Set<Video> videos;

}
