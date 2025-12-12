package com.example.onlinebank.mapper;

import com.example.onlinebank.model.EmailCode;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface EmailCodeMapper {
    int insert(EmailCode code);
    List<EmailCode> findByEmailAndPurpose(@Param("email") String email, @Param("purpose") String purpose);
    int deleteByEmailAndPurpose(@Param("email") String email, @Param("purpose") String purpose);
}