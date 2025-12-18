package com.example.onlinebank.controller;

import com.example.onlinebank.model.EmailCode;
import com.example.onlinebank.model.User;
import com.example.onlinebank.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Random;
import java.util.Set;
import java.util.UUID;

/**
 * 用户控制器
 * 处理用户相关的所有HTTP请求，包括：认证、注册、个人信息、头像上传、
 * 充值、提现、转账、密码重置、账户注销等功能
 */
@Controller
public class UserController {

    /** 用户业务逻辑层，处理所有与用户相关的业务 */
    @Autowired
    private UserService userService;

    /** JavaMail发送者，用于发送邮箱验证码等邮件 */
    @Autowired
    private JavaMailSender mailSender;

    /** 允许上传的头像文件扩展名集合 */
    private static final Set<String> ALLOWED_EXT = new HashSet<>();
    
    /** 头像文件大小限制：2MB */
    private static final long MAX_AVATAR_SIZE = 2L * 1024L * 1024L;

    /**
     * 静态初始化块：初始化允许的图片格式
     * 支持的格式：jpg, jpeg, png, gif, webp
     */
    static {
        ALLOWED_EXT.add("jpg");
        ALLOWED_EXT.add("jpeg");
        ALLOWED_EXT.add("png");
        ALLOWED_EXT.add("gif");
        ALLOWED_EXT.add("webp");
    }

    /**
     * 首页重定向
     * GET / 或 /index → 重定向到登录页面
     * @return 重定向路径
     */
    @GetMapping({"/", "/index"})
    public String index() {
        return "redirect:/login";
    }

    /**
     * 显示登录页面
     * GET /login → 返回 login.jsp
     * @return 视图名称
     */
    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    /**
     * 用户登录处理
     * POST /doLogin
     * @param identifier 用户标识符（邮箱或用户名）
     * @param password   用户密码（明文比对，不安全仅用于演示）
     * @param session    HTTP会话，用于存储userId
     * @param model      模型对象，用于传递错误消息
     * @return 登录成功后：管理员→/admin/dashboard，普通用户→/user/profile；失败→/login
     */
    @PostMapping("/doLogin")
    public String doLogin(@RequestParam("identifier") String identifier,
                          @RequestParam String password,
                          HttpSession session, Model model) {
        User u = userService.findByIdentifier(identifier);
        if (u == null) {
            model.addAttribute("error", "用户不存在");
            return "login";
        }
        if (!userService.checkPassword(u, password)) {
            model.addAttribute("error", "密码错误");
            return "login";
        }
        session.setAttribute("userId", u.getId());

        // 检查是否是管理员
        if (Boolean.TRUE.equals(u.getIsAdmin())) {
            return "redirect:/admin/dashboard";
        } else {
            return "redirect:/user/profile";
        }
    }

    /**
     * 用户登出
     * GET /logout → 清除会话并重定向到登录页面
     * @param session HTTP会话对象
     * @return 重定向路径
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    /**
     * 显示注册页面
     * GET /register → 返回 register.jsp
     * @return 视图名称
     */
    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }

    /**
     * 发送邮箱验证码
     * POST /sendCode
     * 生成6位随机验证码，保存到数据库，并通过邮件发送
     * @param email   接收验证码的邮箱
     * @param purpose 验证码用途：register(注册)、reset(重置密码)、delete_account(注销账户)
     * @return 返回状态：sent(成功)、email_registered(邮箱已注册)、error(参数错误)、send_fail(邮件发送失败)
     */
    @PostMapping("/sendCode")
    @ResponseBody
    public String sendCode(@RequestParam String email, @RequestParam String purpose) {
        // 参数验证：邮箱和用途都不能为空
        if (!StringUtils.hasText(email) || !StringUtils.hasText(purpose)) {
            return "error";
        }
        // 注册场景：检查邮箱是否已被注册
        if ("register".equals(purpose) && userService.findByEmail(email) != null) {
            return "email_registered";
        }
        // 生成6位随机验证码（000000-999999）
        String code = String.format("%06d", new Random().nextInt(999999));
        // 创建验证码对象并保存到数据库
        EmailCode ec = new EmailCode();
        ec.setEmail(email);
        ec.setCode(code);
        ec.setPurpose(purpose);
        userService.saveEmailCode(ec);

        try {
            // 使用JavaMailSender发送验证码邮件
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(email);
            msg.setFrom(((org.springframework.mail.javamail.JavaMailSenderImpl) mailSender).getUsername());
            msg.setSubject("注册验证码");
            msg.setText("您的注册验证码是：" + code);
            mailSender.send(msg);
        } catch (Exception ex) {
            return "send_fail";
        }
        return "sent";
    }

    /**
     * 用户注册处理
     * POST /doRegister
     * 验证邮箱验证码 → 检查邮箱是否已注册 → 创建新用户（默认余额0.00，默认头像）→ 保存到数据库
     * @param email    邮箱
     * @param username 用户名
     * @param password 密码（明文存储，仅用于演示）
     * @param code     邮箱验证码
     * @param model    模型对象，用于传递错误消息
     * @return 注册成功→/login；失败→/register（显示错误消息）
     */
    @PostMapping("/doRegister")
    public String doRegister(@RequestParam String email,
                             @RequestParam String username,
                             @RequestParam String password,
                             @RequestParam String code,
                             Model model) {

        // 步骤1：验证邮箱验证码
        if (!userService.verifyEmailCode(email, "register", code)) {
            model.addAttribute("error", "验证码错误或已过期");
            return "register";
        }
        // 步骤2：检查邮箱是否已被注册
        if (userService.findByEmail(email) != null) {
            model.addAttribute("error", "该邮箱已注册");
            return "register";
        }

        // 步骤3：创建新用户对象
        User u = new User();
        u.setEmail(email);
        u.setUsername(username);
        u.setPassword(password);
        u.setBalance(new BigDecimal("0.00")); // 新用户默认余额为0
        // 设置默认头像
        u.setAvatar("/uploads/default_avatar.png");

        // 步骤4：保存用户到数据库
        userService.register(u);

        return "redirect:/login";
    }

    /**
     * 显示用户个人资料页面
     * GET /user/profile
     * 需要用户已登录（session中存在userId）
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递用户信息
     * @return 已登录→/WEB-INF/views/profile.jsp；未登录→/login
     */
    @GetMapping("/user/profile")
    public String profile(HttpSession session, Model model) {
        // 检查用户是否已登录
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        // 从数据库查询用户信息并传递给视图
        User u = userService.findById(userId);
        model.addAttribute("user", u);
        return "profile";
    }

    /**
     * 头像上传处理
     * POST /user/uploadAvatar
     * 需要用户已登录。验证文件大小、格式 → 生成UUID文件名 → 保存到磁盘 → 更新数据库
     * @param file    上传的文件（MultipartFile）
     * @param session HTTP会话对象
     * @param request HTTP请求对象（用于获取真实路径）
     * @param model   模型对象，用于传递错误消息
     * @return 上传成功→/user/profile；上传失败→/user/profile（显示错误消息）
     */
    @PostMapping("/user/uploadAvatar")
    public String uploadAvatar(@RequestParam("file") MultipartFile file,
                               HttpSession session,
                               HttpServletRequest request,
                               Model model) {
        // 检查用户是否已登录
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        // 1. 检查文件是否为空
        if (file.isEmpty()) {
            model.addAttribute("uploadError", "请选择文件");
            return profile(session, model);
        }

        // 2. 检查文件大小（不超过2MB）
        if (file.getSize() > MAX_AVATAR_SIZE) {
            model.addAttribute("uploadError", "文件过大，请上传2MB以内的图片");
            return profile(session, model);
        }

        // 3. 检查文件类型（只允许特定的图片格式）
        String originalFilename = file.getOriginalFilename();
        String suffix = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            suffix = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        }
        if (!ALLOWED_EXT.contains(suffix)) {
            model.addAttribute("uploadError", "不支持的文件格式");
            return profile(session, model);
        }

        try {
            // 4. 确定保存路径 (webapp/uploads/)
            String realPath = request.getServletContext().getRealPath("/uploads/");
            File dir = new File(realPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // 5. 生成新文件名 (UUID + 后缀)，避免文件名冲突
            String newFileName = UUID.randomUUID().toString() + "." + suffix;

            // 6. 保存文件到磁盘
            file.transferTo(new File(dir, newFileName));

            // 7. 更新数据库中的用户头像路径
            User user = userService.findById(userId);
            // 路径存为 /uploads/xxx.png
            String avatarUrl = "/uploads/" + newFileName;
            user.setAvatar(avatarUrl);

            userService.update(user);

        } catch (IOException e) {
            e.printStackTrace();
            model.addAttribute("uploadError", "上传失败：" + e.getMessage());
            return profile(session, model);
        }

        return "redirect:/user/profile";
    }

    /**
     * 用户充值
     * POST /user/recharge
     * @param amount  充值金额（字符串类型，需要转换为BigDecimal）
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递错误消息
     * @return 充值成功→/user/profile；失败→/user/profile（显示错误消息）
     */
    @PostMapping("/user/recharge")
    public String recharge(@RequestParam String amount, HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        try {
            userService.recharge(userId, new BigDecimal(amount));
        } catch (Exception e) {
            model.addAttribute("error", "充值失败: " + e.getMessage());
            return profile(session, model);
        }
        return "redirect:/user/profile";
    }

    /**
     * 用户提现
     * POST /user/withdraw
     * @param amount  提现金额（字符串类型，需要转换为BigDecimal）
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递错误消息
     * @return 提现成功→/user/profile；失败→/user/profile（显示错误消息）
     */
    @PostMapping("/user/withdraw")
    public String withdraw(@RequestParam String amount, HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        try {
            userService.withdraw(userId, new BigDecimal(amount));
        } catch (Exception e) {
            model.addAttribute("error", "提现失败: " + e.getMessage());
            return profile(session, model);
        }
        return "redirect:/user/profile";
    }

    /**
     * 用户转账
     * POST /user/transfer
     * @param toIdentifier 接收方标识符（邮箱或用户名）
     * @param amount       转账金额（字符串类型，需要转换为BigDecimal）
     * @param session      HTTP会话对象
     * @param model        模型对象，用于传递错误消息
     * @return 转账成功→/user/profile；失败→/user/profile（显示错误消息）
     */
    @PostMapping("/user/transfer")
    public String transfer(@RequestParam String toIdentifier, @RequestParam String amount, HttpSession session, Model model) {
        Long fromId = (Long) session.getAttribute("userId");
        if (fromId == null) return "redirect:/login";

        try {
            // 查询接收方用户
            User toUser = userService.findByIdentifier(toIdentifier);
            if (toUser == null) {
                model.addAttribute("error", "接收方不存在");
                return profile(session, model);
            }
            // 执行转账操作
            userService.transfer(fromId, toUser.getId(), new BigDecimal(amount));
        } catch (Exception e) {
            model.addAttribute("error", "转账失败: " + e.getMessage());
            return profile(session, model);
        }
        return "redirect:/user/profile";
    }

    /**
     * 显示密码重置页面
     * GET /forgot → 返回 forgot.jsp
     * @return 视图名称
     */
    @GetMapping("/forgot")
    public String forgotPage() {
        return "forgot";
    }

    /**
     * 发送密码重置验证码
     * POST /sendResetCode
     * 查询用户 → 生成验证码 → 保存到数据库 → 发送邮件
     * @param email 用户邮箱
     * @return 返回状态：sent(成功)、no_user(邮箱对应用户不存在)、send_fail(邮件发送失败)
     */
    @PostMapping("/sendResetCode")
    @ResponseBody
    public String sendResetCode(@RequestParam String email) {
        // 检查用户是否存在
        User u = userService.findByEmail(email);
        if (u == null) return "no_user";

        try {
            // 生成6位验证码
            String code = String.format("%06d", new Random().nextInt(999999));
            // 创建并保存验证码对象
            EmailCode ec = new EmailCode();
            ec.setEmail(email);
            ec.setCode(code);
            ec.setPurpose("reset");
            userService.saveEmailCode(ec);

            // 发送验证码邮件
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(email);
            msg.setFrom(((org.springframework.mail.javamail.JavaMailSenderImpl) mailSender).getUsername());
            msg.setSubject("重置密码验证码");
            msg.setText("您的验证码是：" + code);
            mailSender.send(msg);

        } catch (Exception ex) {
            return "send_fail";
        }
        return "sent";
    }

    /**
     * 重置密码处理
     * POST /doReset
     * @param email       用户邮箱
     * @param code        邮箱验证码
     * @param newPassword 新密码
     * @param model       模型对象，用于传递错误消息
     * @return 重置成功→/login；失败→/forgot（显示错误消息）
     */
    @PostMapping("/doReset")
    public String doReset(@RequestParam String email,
                          @RequestParam String code,
                          @RequestParam String newPassword,
                          Model model) {

        // 验证验证码
        if (!userService.verifyEmailCode(email, "reset", code)) {
            model.addAttribute("error", "验证码错误或已过期");
            return "forgot";
        }

        try {
            // 重置密码
            userService.resetPassword(email, newPassword);
        } catch (Exception ex) {
            model.addAttribute("error", "重置失败：" + ex.getMessage());
            return "forgot";
        }

        return "redirect:/login";
    }


    /**
     * 显示账户注销页面
     * GET /user/deleteAccount
     * 检查用户余额是否为0（只有余额为0才能注销）
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递用户信息和余额状态
     * @return 已登录→/WEB-INF/views/deleteAccount.jsp；未登录→/login
     */
    @GetMapping("/user/deleteAccount")
    public String deleteAccountPage(HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        User user = userService.findById(userId);
        model.addAttribute("user", user);

        // 添加余额是否为零的判断
        boolean isBalanceZero = user.getBalance().compareTo(BigDecimal.ZERO) == 0;
        model.addAttribute("isBalanceZero", isBalanceZero);

        return "deleteAccount";
    }

    /**
     * 发送账户注销验证码
     * POST /user/sendDeleteCode
     * @param session HTTP会话对象
     * @return 返回状态：sent(成功)、not_logged_in(未登录)、no_user(用户不存在)、send_fail(邮件发送失败)
     */
    @PostMapping("/user/sendDeleteCode")
    @ResponseBody
    public String sendDeleteCode(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "not_logged_in";

        User user = userService.findById(userId);
        if (user == null) return "no_user";

        String email = user.getEmail();
        String purpose = "delete_account";

        try {
            // 生成验证码
            String code = String.format("%06d", new Random().nextInt(999999));
            // 保存验证码
            EmailCode ec = new EmailCode();
            ec.setEmail(email);
            ec.setCode(code);
            ec.setPurpose(purpose);
            userService.saveEmailCode(ec);

            // 发送验证码邮件
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(email);
            msg.setFrom(((org.springframework.mail.javamail.JavaMailSenderImpl) mailSender).getUsername());
            msg.setSubject("账号注销验证码");
            msg.setText("您正在申请注销网上银行账号，验证码是：" + code + "。此操作将永久删除您的账号，请谨慎操作！");
            mailSender.send(msg);

        } catch (Exception ex) {
            return "send_fail";
        }
        return "sent";
    }

    /**
     * 确认账户注销
     * POST /user/confirmDelete
     * 验证验证码 → 检查用户存在 → 检查余额是否为0 → 删除用户 → 清除会话
     * @param code    邮箱验证码
     * @param session HTTP会话对象
     * @param model   模型对象，用于传递错误消息
     * @param request HTTP请求对象（用于获取上传的头像文件路径）
     * @return 注销成功→/login；失败→/user/deleteAccount（显示错误消息）
     */
    @PostMapping("/user/confirmDelete")
    public String confirmDelete(@RequestParam String code,
                                HttpSession session,
                                Model model,
                                HttpServletRequest request) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        User user = userService.findById(userId);
        if (user == null) {
            model.addAttribute("error", "用户不存在");
            return "deleteAccount";
        }

        String email = user.getEmail();

        // 步骤1：验证验证码
        if (!userService.verifyEmailCode(email, "delete_account", code)) {
            model.addAttribute("error", "验证码错误或已过期");
            model.addAttribute("user", user);
            return "deleteAccount";
        }

        try {
            // 步骤2：删除用户（服务层会检查余额是否为0）
            userService.deleteUser(userId);

            // 步骤3：删除用户上传的头像文件（如果存在）
            if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
                String avatarPath = request.getServletContext().getRealPath(user.getAvatar());
                File avatarFile = new File(avatarPath);
                if (avatarFile.exists()) {
                    avatarFile.delete();
                }
            }

            // 步骤4：清除session，强制登出
            session.invalidate();

            return "redirect:/login";

        } catch (Exception e) {
            model.addAttribute("error", "注销失败: " + e.getMessage());
            model.addAttribute("user", user);
            return "deleteAccount";
        }
    }

}