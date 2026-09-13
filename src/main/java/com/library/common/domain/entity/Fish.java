package com.library.common.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Fish {
    private int id;
    private String name;
    private String fishClass;
    private String order;
    private String family;
    private String genus;
    private String description;
    private String imageUrl;
    private String scientificName;
}
