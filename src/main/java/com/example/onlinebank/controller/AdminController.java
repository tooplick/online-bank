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

@Controller
public class AdminController {

    @Autowired
    private UserService userService;

    // 管理员主页
    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpSession session, Model model) {
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

    // 用户管理页面
    @GetMapping("/admin/users")
    public String manageUsers(HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        // 检查是否是管理员
        User admin = userService.findById(userId);
        if (admin == null || !Boolean.TRUE.equals(admin.getIsAdmin())) {
            return "redirect:/user/profile";
        }

        // 获取所有用户列表
        List<User> users = userService.getAllUsers();
        model.addAttribute("users", users);
        model.addAttribute("admin", admin);

        return "admin/users";
    }

    // 调整用户余额
    @PostMapping("/admin/adjustBalance")
    @ResponseBody
    public String adjustBalance(@RequestParam Long userId,
                                @RequestParam String amount,
                                @RequestParam String operation,
                                HttpSession session) {
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

            if ("add".equals(operation)) {
                // 增加余额
                userService.recharge(userId, adjustAmount);
                return "success";
            } else if ("subtract".equals(operation)) {
                // 减少余额，但不能小于0
                if (targetUser.getBalance().compareTo(adjustAmount) < 0) {
                    return "insufficient_balance";
                }
                userService.withdraw(userId, adjustAmount);
                return "success";
            } else if ("set".equals(operation)) {
                return "operation_not_supported";
            }

            return "invalid_operation";

        } catch (Exception e) {
            return "error: " + e.getMessage();
        }
    }

    // 删除用户
    @PostMapping("/admin/deleteUser")
    @ResponseBody
    public String deleteUser(@RequestParam Long userId, HttpSession session) {
        Long adminId = (Long) session.getAttribute("userId");
        if (adminId == null) return "not_logged_in";

        // 检查是否是管理员
        User admin = userService.findById(adminId);
        if (admin == null || !Boolean.TRUE.equals(admin.getIsAdmin())) {
            return "not_admin";
        }

        // 不能删除自己
        if (adminId.equals(userId)) {
            return "cannot_delete_self";
        }

        try {
            // 直接删除，不需要检查余额
            User targetUser = userService.findById(userId);
            if (targetUser == null) {
                return "user_not_found";
            }

            // 删除用户
            int result = userService.deleteUserByAdmin(userId);
            return result > 0 ? "success" : "delete_failed";

        } catch (Exception e) {
            return "error: " + e.getMessage();
        }
    }
}