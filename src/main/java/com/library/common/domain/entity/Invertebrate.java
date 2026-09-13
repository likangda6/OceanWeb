package com.library.common.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Invertebrate {
    private int id;
    private String name;
    private String fishClass;
    private String order;
    private String family;
    private String description;
    private String imageUrl;
}
