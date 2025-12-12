package com.example.onlinebank.mapper;

import com.example.onlinebank.model.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface UserMapper {

    User findByEmail(String email);

    User findById(Long id);

    User findByIdentifier(String identifier);

    int insert(User user);

    int update(User user);

    int updateBalance(@Param("id") Long id, @Param("amount") BigDecimal amount);


    int deleteById(Long userId);

    List<User> findAll();
    int countAll();
    BigDecimal sumAllBalance();
}
