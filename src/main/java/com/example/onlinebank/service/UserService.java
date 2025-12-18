package com.example.onlinebank.service;

import com.example.onlinebank.mapper.EmailCodeMapper;
import com.example.onlinebank.mapper.UserMapper;
import com.example.onlinebank.model.EmailCode;
import com.example.onlinebank.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户业务逻辑层服务类
 * 处理所有与用户相关的业务逻辑，包括：查询、注册、认证、金融交易、
 * 邮箱验证码管理、密码重置、账户注销等
 * 
 * 金融交易操作使用@Transactional注解确保事务一致性
 */
@Service
public class UserService {

    /** 用户数据访问接口，处理用户表的CRUD操作 */
    @Autowired
    private UserMapper userMapper;

    /** 邮箱验证码数据访问接口，处理验证码表的操作 */
    @Autowired
    private EmailCodeMapper emailCodeMapper;

    /**
     * 根据邮箱查询用户
     * @param email 邮箱地址
     * @return 用户对象，如果不存在则返回null
     */
    public User findByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    /**
     * 根据用户ID查询用户
     * @param id 用户ID
     * @return 用户对象，如果不存在则返回null
     */
    public User findById(Long id) {
        return userMapper.findById(id);
    }

    /**
     * 根据用户标识符（邮箱或用户名）查询用户
     * @param identifier 邮箱或用户名
     * @return 用户对象，如果不存在则返回null
     */
    public User findByIdentifier(String identifier) {
        if (identifier == null) return null;
        return userMapper.findByIdentifier(identifier);
    }

    /**
     * 更新用户信息
     * @param user 用户对象（包含id和需要更新的字段）
     * @return 影响的行数
     */
    public int update(User user) {
        return userMapper.update(user);
    }

    /**
     * 用户注册
     * @param user 新用户对象
     * @return 影响的行数
     */
    public int register(User user) {
        // 确保新用户的初始余额为0.00
        if (user.getBalance() == null) {
            user.setBalance(new BigDecimal("0.00"));
        }
        return userMapper.insert(user);
    }

    /**
     * 检验密码是否正确
     * 使用明文比对（仅用于演示，生产环境应使用加密算法）
     * @param user      用户对象
     * @param rawPassword 用户输入的密码（明文）
     * @return true表示密码正确，false表示密码错误或用户/密码为空
     */
    public boolean checkPassword(User user, String rawPassword) {
        if (user == null) return false;
        if (rawPassword == null) return false;
        return rawPassword.equals(user.getPassword());
    }

    /**
     * 充值操作（添加余额）
     * 使用@Transactional保证事务性
     * @param userId 用户ID
     * @param amount 充值金额
     * @throws IllegalArgumentException 如果金额不合法
     */
    @Transactional
    public void recharge(Long userId, BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("充值金额必须大于0");
        }
        userMapper.updateBalance(userId, amount);
    }

    /**
     * 提现操作（减少余额）
     * 检查余额是否充足，使用@Transactional保证事务性
     * @param userId 用户ID
     * @param amount 提现金额
     * @throws IllegalArgumentException 如果金额不合法或余额不足
     */
    @Transactional
    public void withdraw(Long userId, BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("提现金额必须大于0");
        }
        User u = userMapper.findById(userId);
        if (u == null) {
            throw new IllegalArgumentException("用户不存在");
        }
        if (u.getBalance().compareTo(amount) < 0) {
            throw new IllegalArgumentException("余额不足");
        }
        // 余额减少，使用negate()获得负数
        userMapper.updateBalance(userId, amount.negate());
    }

    /**
     * 转账操作（一方减少，另一方增加）
     * 检查：1.转账者和接收者不能相同 2.金额合法性 3.用户存在性 4.余额充足
     * 使用@Transactional保证两个操作的原子性
     * @param fromId   转账者用户ID
     * @param toId     接收者用户ID
     * @param amount   转账金额
     * @throws IllegalArgumentException 如果参数不合法
     */
    @Transactional
    public void transfer(Long fromId, Long toId, BigDecimal amount) {
        // 检查：不能转给自己
        if (fromId.equals(toId)) {
            throw new IllegalArgumentException("不能转给自己");
        }
        // 检查：金额必须大于0
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("转账金额必须大于0");
        }
        User from = userMapper.findById(fromId);
        User to = userMapper.findById(toId);
        // 检查：两个用户都必须存在
        if (from == null || to == null) {
            throw new IllegalArgumentException("发起方或接收方不存在");
        }
        // 检查：余额充足
        if (from.getBalance().compareTo(amount) < 0) {
            throw new IllegalArgumentException("余额不足");
        }
        // 执行转账：先减，后加
        userMapper.updateBalance(fromId, amount.negate());
        userMapper.updateBalance(toId, amount);
    }

    /**
     * 保存邮箱验证码到数据库
     * @param code 验证码对象
     * @return 影响的行数
     */
    public int saveEmailCode(EmailCode code) {
        return emailCodeMapper.insert(code);
    }

    /**
     * 验证邮箱验证码
     * 验证成功后，自动删除该验证码（一次性使用）
     * @param email   邮箱地址
     * @param purpose 验证码用途
     * @param code    输入的验证码
     * @return true表示验证通过，false表示验证失败或验证码不存在
     */
    public boolean verifyEmailCode(String email, String purpose, String code) {
        List<EmailCode> list = emailCodeMapper.findByEmailAndPurpose(email, purpose);
        if (list == null || list.isEmpty()) {
            return false;
        }
        for (EmailCode c : list) {
            if (c.getCode().equals(code)) {
                // 验证成功，删除所有该邮箱和用途的验证码（防止重复使用）
                emailCodeMapper.deleteByEmailAndPurpose(email, purpose);
                return true;
            }
        }
        return false;
    }

    /**
     * 重置用户密码
     * @param email       邮箱地址
     * @param newPassword 新密码
     * @throws IllegalArgumentException 如果邮箱对应的用户不存在
     */
    public void resetPassword(String email, String newPassword) {
        User u = userMapper.findByEmail(email);
        if (u == null) {
            throw new IllegalArgumentException("邮件对应用户不存在");
        }
        u.setPassword(newPassword);
        userMapper.update(u);
    }

    /**
     * 删除用户账户
     * 仅允许余额为0的用户注销账号，防止资金丢失
     * @param userId 用户ID
     * @return 影响的行数
     * @throws IllegalArgumentException 如果用户不存在或余额不为0
     */
    @Transactional
    public int deleteUser(Long userId) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new IllegalArgumentException("用户不存在");
        }
        // 检查余额是否为零
        if (user.getBalance().compareTo(BigDecimal.ZERO) != 0) {
            throw new IllegalArgumentException("账户余额不为零，无法注销账号");
        }
        return userMapper.deleteById(userId);
    }

    /**
     * 获取所有用户列表
     * @return 用户列表
     */
    public List<User> getAllUsers() {
        return userMapper.findAll();
    }

    /**
     * 获取用户总数
     * @return 用户数量
     */
    public int getAllUsersCount() {
        return userMapper.countAll();
    }

    /**
     * 获取系统所有用户的总余额
     * @return 总余额
     */
    public BigDecimal getTotalBalance() {
        return userMapper.sumAllBalance();
    }

    /**
     * 管理员删除用户（不检查余额）
     * 仅供管理员使用，不受余额限制
     * @param userId 用户ID
     * @return 影响的行数
     */
    @Transactional
    public int deleteUserByAdmin(Long userId) {
        return userMapper.deleteById(userId);
    }

    /**
     * 分页查询用户
     * @param pageNum  页码（从1开始）
     * @param pageSize 每页条数
     * @return 包含以下key的Map：
     *         - users: 当前页用户列表
     *         - currentPage: 当前页码
     *         - totalPages: 总页数
     *         - totalUsers: 用户总数
     */
    public Map<String, Object> getUsersWithPagination(int pageNum, int pageSize) {
        // 1. 计算偏移量：(pageNum - 1) * pageSize
        int offset = (pageNum - 1) * pageSize;

        // 2. 查询当前页的用户数据
        List<User> users = userMapper.selectByPage(offset, pageSize);

        // 3. 查询用户总数
        int totalUsers = userMapper.countAll();

        // 4. 计算总页数
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        // 5. 封装分页结果
        Map<String, Object> result = new HashMap<>();
        result.put("users", users);
        result.put("currentPage", pageNum);
        result.put("totalPages", totalPages);
        result.put("totalUsers", totalUsers);

        return result;
    }
}