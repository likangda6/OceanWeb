package com.library.common.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Species {
    private Integer id;
    private String name;
    private String fishClass;
    private String order;
    private String family;
    private String description;
    private String imageUrl;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}
