package com.pi.springboot.model;

import java.io.Serializable;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Data
@NoArgsConstructor
@Entity
@Getter
@Setter
@Table
@ToString
public class Video implements Serializable{
	
	static final long serialVersionUID = 137L;
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;
	
	@Column
	private String titol;
	
	@Column(name="url")
	private String videoURL;
	
	@Column(name="thumbnail")
	private String thumbnailURL;
	
	@Column
	private int duracio;
}
