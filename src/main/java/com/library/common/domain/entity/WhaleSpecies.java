package com.library.common.domain.entity;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WhaleSpecies {
    private int id;
    private String fishClass;
    private String name;
    private String order;
    private String family;
    private String genus;
    private String description;
    private String imageUrl;
}
