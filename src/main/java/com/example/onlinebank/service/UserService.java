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

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private EmailCodeMapper emailCodeMapper;

    public User findByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    public User findById(Long id) {
        return userMapper.findById(id);
    }

    public User findByIdentifier(String identifier) {
        if (identifier == null) return null;
        return userMapper.findByIdentifier(identifier);
    }

    public int update(User user) {
        return userMapper.update(user);
    }

    public int register(User user) {
        if (user.getBalance() == null) {
            user.setBalance(new BigDecimal("0.00"));
        }
        return userMapper.insert(user);
    }

    public boolean checkPassword(User user, String rawPassword) {
        if (user == null) return false;
        if (rawPassword == null) return false;
        return rawPassword.equals(user.getPassword());
    }

    @Transactional
    public void recharge(Long userId, BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("充值金额必须大于0");
        }
        userMapper.updateBalance(userId, amount);
    }

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
        userMapper.updateBalance(userId, amount.negate());
    }

    @Transactional
    public void transfer(Long fromId, Long toId, BigDecimal amount) {
        if (fromId.equals(toId)) {
            throw new IllegalArgumentException("不能转给自己");
        }
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("转账金额必须大于0");
        }
        User from = userMapper.findById(fromId);
        User to = userMapper.findById(toId);
        if (from == null || to == null) {
            throw new IllegalArgumentException("发起方或接收方不存在");
        }
        if (from.getBalance().compareTo(amount) < 0) {
            throw new IllegalArgumentException("余额不足");
        }
        userMapper.updateBalance(fromId, amount.negate());
        userMapper.updateBalance(toId, amount);
    }

    public int saveEmailCode(EmailCode code) {
        return emailCodeMapper.insert(code);
    }

    public boolean verifyEmailCode(String email, String purpose, String code) {
        List<EmailCode> list = emailCodeMapper.findByEmailAndPurpose(email, purpose);
        if (list == null || list.isEmpty()) {
            return false;
        }
        for (EmailCode c : list) {
            if (c.getCode().equals(code)) {
                emailCodeMapper.deleteByEmailAndPurpose(email, purpose);
                return true;
            }
        }
        return false;
    }

    public void resetPassword(String email, String newPassword) {
        User u = userMapper.findByEmail(email);
        if (u == null) {
            throw new IllegalArgumentException("邮件对应用户不存在");
        }
        u.setPassword(newPassword);
        userMapper.update(u);
    }

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

    // 在 UserService.java 中添加以下方法：

// --- 管理员相关方法 ---

    /**
     * 获取所有用户列表
     * @return 用户列表
     */
    public List<User> getAllUsers() {
        // 需要先在UserMapper中添加对应方法
        return userMapper.findAll();
    }

    /**
     * 获取用户总数
     * @return 用户数量
     */
    public int getAllUsersCount() {
        // 需要先在UserMapper中添加对应方法
        return userMapper.countAll();
    }

    /**
     * 获取系统总余额
     * @return 总余额
     */
    public BigDecimal getTotalBalance() {
        // 需要先在UserMapper中添加对应方法
        return userMapper.sumAllBalance();
    }

    /**
     * 管理员删除用户（不检查余额）
     * @param userId 用户ID
     * @return 影响的行数
     */
    @Transactional
    public int deleteUserByAdmin(Long userId) {
        return userMapper.deleteById(userId);
    }

    // 在 UserService.java 中添加：

    public Map<String, Object> getUsersWithPagination(int pageNum, int pageSize) {
        // 1. 计算偏移量
        int offset = (pageNum - 1) * pageSize;

        // 2. 查询当前页数据
        List<User> users = userMapper.selectByPage(offset, pageSize);

        // 3. 查询总记录数 (利用现有的 countAll 方法)
        int totalUsers = userMapper.countAll();

        // 4. 计算总页数
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        // 5. 封装结果
        Map<String, Object> result = new HashMap<>();
        result.put("users", users);
        result.put("currentPage", pageNum);
        result.put("totalPages", totalPages);
        result.put("totalUsers", totalUsers);

        return result;
    }
}