create database oceanWeb;

use oceanWeb;

create table fish_species
(
id              int auto_increment
primary key,
scientific_name varchar(100)                        not null comment '科学名称',
fishClass       varchar(50)                         not null comment '纲',
`order`         varchar(50)                         not null comment '目',
family          varchar(50)                         not null comment '科',
name            varchar(100)                        null comment '方言名称',
description     text                                null comment '简介',
image_url       varchar(1000)                       null comment '图片链接',
created_at      timestamp default CURRENT_TIMESTAMP null,
updated_at      timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP
)
comment '鱼类物种信息表';

create index idx_class
on fish_species (fishClass);

create index idx_family
on fish_species (family);

create index idx_order
on fish_species (`order`);

create index idx_scientific_name
on fish_species (scientific_name);


create table whale_species
(
id          int auto_increment
primary key,
name        varchar(100)                          not null comment '代表物种',
`order`     varchar(50)                           not null comment '目（Order）',
family      varchar(50)                           not null comment '科（Family）',
genus       varchar(50)                           not null comment '属（Genus）',
description text                                  null comment '段落内容',
image_url   varchar(255)                          null comment '图片链接',
created_at  timestamp   default CURRENT_TIMESTAMP null,
updated_at  timestamp   default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
fishClass   varchar(50) default '哺乳纲'          not null comment '纲'
)
comment '鲸类物种信息表';




