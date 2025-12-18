package com.example.onlinebank.model;

import java.util.Date;

/**
 * 邮箱验证码模型类
 * 对应数据库email_codes表
 * 用于存储用户邮箱验证码（一次性使用）
 * 
 * 表结构说明：
 * - id: 自增主键
 * - email: 邮箱地址
 * - code: 6位数字验证码
 * - purpose: 验证码用途（register、reset、delete_account等）
 * - created_at: 验证码生成时间
 */
public class EmailCode {
    /** 验证码ID（自增主键） */
    private Long id;
    
    /** 邮箱地址 */
    private String email;
    
    /** 6位数字验证码 */
    private String code;
    
    /** 验证码用途：register(注册)、reset(重置密码)、delete_account(注销账户) */
    private String purpose;
    
    /** 验证码生成时间（由数据库CURRENT_TIMESTAMP自动生成） */
    private Date createdAt;

    /**
     * 无参构造函数
     */
    public EmailCode() {
    }

    /**
     * 获取验证码ID
     * @return 验证码ID
     */
    public Long getId() {
        return id;
    }

    /**
     * 设置验证码ID
     * @param id 验证码ID
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * 获取邮箱地址
     * @return 邮箱地址
     */
    public String getEmail() {
        return email;
    }

    /**
     * 设置邮箱地址
     * @param email 邮箱地址
     */
    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * 获取验证码
     * @return 6位数字验证码
     */
    public String getCode() {
        return code;
    }

    /**
     * 设置验证码
     * @param code 6位数字验证码
     */
    public void setCode(String code) {
        this.code = code;
    }

    /**
     * 获取验证码用途
     * @return 用途字符串（register、reset、delete_account）
     */
    public String getPurpose() {
        return purpose;
    }

    /**
     * 设置验证码用途
     * @param purpose 用途字符串
     */
    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    /**
     * 获取验证码生成时间
     * @return 生成时间
     */
    public Date getCreatedAt() {
        return createdAt;
    }

    /**
     * 设置验证码生成时间
     * @param createdAt 生成时间
     */
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}