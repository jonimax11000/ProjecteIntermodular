package com.pi.springboot.model;

import java.io.Serializable;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@Entity
@Table
@ToString
public class Edat implements Serializable {

	static final long serialVersionUID = 137L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@Column(nullable = false, unique = true)
	private Integer edat;

}
