package com.example.onlinebank.controller;

import com.example.onlinebank.model.User;
import com.example.onlinebank.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 管理员控制器
 * 处理管理员相关的HTTP请求，包括：
 * - 管理员仪表板（系统统计信息）
 * - 用户管理（分页查询、用户信息展示）
 * - 余额调整（充值、提现）
 * - 用户删除
 * 
 * 所有接口都需要管理员权限验证（isAdmin=true）
 */
@Controller
public class AdminController {

    /** 用户业务逻辑层，处理所有与用户相关的业务 */
    @Autowired
    private UserService userService;

    /**
     * 管理员仪表板（首页）
     * GET /admin/dashboard
     * 显示系统统计信息：用户总数、系统总余额
     * 需要管理员权限验证
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递统计数据
     * @return 已登录且是管理员→/WEB-INF/views/admin/dashboard.jsp；
     *         未登录→/login；非管理员→/user/profile
     */
    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpSession session, Model model) {
        // 检查是否已登录
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        // 检查是否是管理员
        User user = userService.findById(userId);
        if (user == null || !Boolean.TRUE.equals(user.getIsAdmin())) {
            return "redirect:/user/profile";
        }

        // 获取系统统计信息
        int totalUsers = userService.getAllUsersCount();
        BigDecimal totalBalance = userService.getTotalBalance();

        model.addAttribute("admin", user);
        model.addAttribute("totalUsers", totalUsers);
        model.addAttribute("totalBalance", totalBalance);

        return "admin/dashboard";
    }

    /**
     * 用户管理页面（分页显示用户列表）
     * GET /admin/users?page=1
     * 显示用户列表，支持分页（每页10条）
     * @param page    页码（默认为1）
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递用户列表和分页信息
     * @return 已登录且是管理员→/WEB-INF/views/admin/users.jsp；
     *         未登录→/login；非管理员→/user/profile
     */
    @GetMapping("/admin/users")
    public String manageUsers(@RequestParam(value = "page", defaultValue = "1") int page,
                              HttpSession session,
                              Model model) {

        // 步骤1：检查用户是否已登录
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";
        
        // 步骤2：检查是否是管理员
        User admin = userService.findById(userId);
        if (admin == null || !Boolean.TRUE.equals(admin.getIsAdmin())) {
            return "redirect:/user/profile";
        }

        // 步骤3：分页查询用户列表
        int pageSize = 10; // 每页显示10条记录
        // 防止页码小于1
        if (page < 1) page = 1;

        Map<String, Object> data = userService.getUsersWithPagination(page, pageSize);

        // 步骤4：传递数据到视图
        model.addAttribute("users", data.get("users"));
        model.addAttribute("currentPage", data.get("currentPage"));
        model.addAttribute("totalPages", data.get("totalPages"));
        model.addAttribute("admin", admin); // 保留管理员信息以便显示头像等

        return "admin/users";
    }

    /**
     * 调整用户余额（增加或减少）
     * POST /admin/adjustBalance
     * 仅管理员可操作，支持两种操作：add(增加)、subtract(减少)
     * @param userId     目标用户ID
     * @param amount     金额（字符串类型，需要转换为BigDecimal）
     * @param operation  操作类型：add(增加)或subtract(减少)
     * @param session    HTTP会话对象
     * @return 返回状态字符串：
     *         - success: 操作成功
     *         - not_logged_in: 未登录
     *         - not_admin: 没有管理员权限
     *         - user_not_found: 目标用户不存在
     *         - insufficient_balance: 余额不足（仅减少操作）
     *         - invalid_operation: 无效的操作类型
     *         - error: 其他错误
     */
    @PostMapping("/admin/adjustBalance")
    @ResponseBody
    public String adjustBalance(@RequestParam Long userId,
                                @RequestParam String amount,
                                @RequestParam String operation,
                                HttpSession session) {
        // 检查是否已登录
        Long adminId = (Long) session.getAttribute("userId");
        if (adminId == null) return "not_logged_in";

        // 检查是否是管理员
        User admin = userService.findById(adminId);
        if (admin == null || !Boolean.TRUE.equals(admin.getIsAdmin())) {
            return "not_admin";
        }

        try {
            BigDecimal adjustAmount = new BigDecimal(amount);
            User targetUser = userService.findById(userId);

            if (targetUser == null) {
                return "user_not_found";
            }

            // 根据操作类型执行相应的业务逻辑
            if ("add".equals(operation)) {
                // 增加余额（充值）
                userService.recharge(userId, adjustAmount);
                return "success";
            } else if ("subtract".equals(operation)) {
                // 减少余额（提现），但不能让余额变为负数
                if (targetUser.getBalance().compareTo(adjustAmount) < 0) {
                    return "insufficient_balance";
                }
                userService.withdraw(userId, adjustAmount);
                return "success";
            } else if ("set".equals(operation)) {
                // 直接设置余额（此功能未实现）
                return "operation_not_supported";
            }

            return "invalid_operation";

        } catch (Exception e) {
            return "error: " + e.getMessage();
        }
    }

    /**
     * 删除用户
     * POST /admin/deleteUser
     * 仅管理员可操作，不能删除自己
     * @param userId  目标用户ID
     * @param session HTTP会话对象
     * @return 返回状态字符串：
     *         - success: 删除成功
     *         - not_logged_in: 未登录
     *         - not_admin: 没有管理员权限
     *         - user_not_found: 目标用户不存在
     *         - cannot_delete_self: 不能删除自己
     *         - delete_failed: 删除失败
     *         - error: 其他错误
     */
    @PostMapping("/admin/deleteUser")
    @ResponseBody
    public String deleteUser(@RequestParam Long userId, HttpSession session) {
        // 检查是否已登录
        Long adminId = (Long) session.getAttribute("userId");
        if (adminId == null) return "not_logged_in";

        // 检查是否是管理员
        User admin = userService.findById(adminId);
        if (admin == null || !Boolean.TRUE.equals(admin.getIsAdmin())) {
            return "not_admin";
        }

        // 检查：不能删除自己
        if (adminId.equals(userId)) {
            return "cannot_delete_self";
        }

        try {
            User targetUser = userService.findById(userId);
            if (targetUser == null) {
                return "user_not_found";
            }

            // 调用管理员专用的删除方法（不检查余额）
            int result = userService.deleteUserByAdmin(userId);
            return result > 0 ? "success" : "delete_failed";

        } catch (Exception e) {
            return "error: " + e.getMessage();
        }
    }
}