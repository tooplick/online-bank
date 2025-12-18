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

     /**
      * 获取所有用户
      * @return 用户列表
      */
    List<User> findAll();
    int countAll();
    BigDecimal sumAllBalance();

    /**
     * 分页查询用户
     * @param offset 跳过的记录数
     * @param limit 每页显示的记录数
     * @return 用户列表
     */
    List<User> selectByPage(@Param("offset") int offset, @Param("limit") int limit);
}
