package com.example.onlinebank.model;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 用户模型类
 * 对应数据库users表
 * 
 * 表结构说明：
 * - id: 自增主键
 * - email: 邮箱，唯一索引
 * - username: 用户名
 * - password: 密码（明文存储，仅用于演示，生产环境应使用加密）
 * - balance: 账户余额，使用BigDecimal存储以避免浮点精度问题
 * - avatar: 用户头像URL路径
 * - created_at: 账户创建时间
 * - is_admin: 是否为管理员（0=否，1=是）
 */
public class User {
    /** 用户ID（自增主键） */
    private Long id;
    
    /** 邮箱地址（唯一索引，用于登录、验证码等） */
    private String email;
    
    /** 用户名（用于登录） */
    private String username;
    
    /** 用户密码（明文存储，仅用于演示 - 生产环境应使用加密算法如BCrypt） */
    private String password;
    
    /** 账户余额（使用BigDecimal确保金融计算精度） */
    private BigDecimal balance;
    
    /** 用户头像路径（相对路径，如 /uploads/xxx.png） */
    private String avatar;
    
    /** 账户创建时间（由数据库CURRENT_TIMESTAMP自动生成） */
    private Date createdAt;
    
    /** 管理员标志（true=管理员，false=普通用户） */
    private Boolean isAdmin;

    /**
     * 无参构造函数
     */
    public User() {
    }

    /**
     * 获取用户ID
     * @return 用户ID
     */
    public Long getId() {
        return id;
    }

    /**
     * 设置用户ID
     * @param id 用户ID
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * 获取邮箱
     * @return 邮箱地址
     */
    public String getEmail() {
        return email;
    }

    /**
     * 设置邮箱
     * @param email 邮箱地址
     */
    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * 获取用户名
     * @return 用户名
     */
    public String getUsername() {
        return username;
    }

    /**
     * 设置用户名
     * @param username 用户名
     */
    public void setUsername(String username) {
        this.username = username;
    }

    /**
     * 获取密码
     * @return 密码（明文）
     */
    public String getPassword() {
        return password;
    }

    /**
     * 设置密码
     * ⚠️ 警告：这是明文密码保存（不安全，仅作作业演示）
     * 生产环境应使用加密算法（如BCrypt）处理密码
     * @param password 密码
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * 获取账户余额
     * @return 账户余额
     */
    public BigDecimal getBalance() {
        return balance;
    }

    /**
     * 设置账户余额
     * 应使用BigDecimal构造，例如：new BigDecimal("100.00")
     * @param balance 账户余额
     */
    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    /**
     * 获取头像路径
     * @return 头像URL路径
     */
    public String getAvatar() {
        return avatar;
    }

    /**
     * 设置头像路径
     * @param avatar 头像URL路径，例如 /uploads/xxx.png
     */
    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    /**
     * 获取账户创建时间
     * @return 创建时间
     */
    public Date getCreatedAt() {
        return createdAt;
    }

    /**
     * 设置账户创建时间
     * @param createdAt 创建时间
     */
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * 获取管理员标志
     * @return true表示是管理员，false表示普通用户
     */
    public Boolean getIsAdmin() {
        return isAdmin;
    }

    /**
     * 设置管理员标志
     * @param isAdmin true表示管理员，false表示普通用户
     */
    public void setIsAdmin(Boolean isAdmin) {
        this.isAdmin = isAdmin;
    }
}