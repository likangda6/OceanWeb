package com.library.service.impl;

import com.library.common.domain.entity.Invertebrate;
import com.library.mapper.InvertebrateMapper;
import com.library.service.InvertebrateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class InvertebrateServiceImpl implements InvertebrateService {
    @Autowired
    private InvertebrateMapper invertebrateMapper;

    @Override
    public Invertebrate getInvertebrateByName(String name){
        return  invertebrateMapper.getInvertebrateByName(name);
    }

    @Override
    public int addInvertebrate(Invertebrate invertebrate) {
        return invertebrateMapper.insertInvertebrate(invertebrate);
    }

    @Override
    public int updateInvertebrate(Invertebrate invertebrate) {
        return invertebrateMapper.updateInvertebrate(invertebrate);
    }

    @Override
    public int deleteInvertebrate(Integer id) {
        return invertebrateMapper.deleteInvertebrate(id);
    }
}
