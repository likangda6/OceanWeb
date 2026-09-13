package com.library.service;

import com.library.common.domain.entity.Invertebrate;

public interface InvertebrateService {
    Invertebrate getInvertebrateByName(String name);

    int addInvertebrate(Invertebrate invertebrate);
    int updateInvertebrate(Invertebrate invertebrate);
    int deleteInvertebrate(Integer id);
}
