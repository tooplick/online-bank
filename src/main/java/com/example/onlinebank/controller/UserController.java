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

@Controller
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private JavaMailSender mailSender;

    // 允许的头像后缀
    private static final Set<String> ALLOWED_EXT = new HashSet<>();
    private static final long MAX_AVATAR_SIZE = 2L * 1024L * 1024L; // 2MB

    static {
        ALLOWED_EXT.add("jpg");
        ALLOWED_EXT.add("jpeg");
        ALLOWED_EXT.add("png");
        ALLOWED_EXT.add("gif");
        ALLOWED_EXT.add("webp");
    }

    // 首页
    @GetMapping({"/", "/index"})
    public String index() {
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    // 修改登录方法，添加管理员判断
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

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    // 注册页
    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }

    // 发送注册验证码
    @PostMapping("/sendCode")
    @ResponseBody
    public String sendCode(@RequestParam String email, @RequestParam String purpose) {
        if (!StringUtils.hasText(email) || !StringUtils.hasText(purpose)) {
            return "error";
        }
        // 判断邮箱是否已注册
        if ("register".equals(purpose) && userService.findByEmail(email) != null) {
            return "email_registered";
        }
        String code = String.format("%06d", new Random().nextInt(999999));
        EmailCode ec = new EmailCode();
        ec.setEmail(email);
        ec.setCode(code);
        ec.setPurpose(purpose);
        userService.saveEmailCode(ec);

        try {
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

    @PostMapping("/doRegister")
    public String doRegister(@RequestParam String email,
                             @RequestParam String username,
                             @RequestParam String password,
                             @RequestParam String code,
                             Model model) {

        if (!userService.verifyEmailCode(email, "register", code)) {
            model.addAttribute("error", "验证码错误或已过期");
            return "register";
        }
        if (userService.findByEmail(email) != null) {
            model.addAttribute("error", "该邮箱已注册");
            return "register";
        }

        User u = new User();
        u.setEmail(email);
        u.setUsername(username);
        u.setPassword(password);
        u.setBalance(new BigDecimal("0.00"));

        // 设置默认头像
        u.setAvatar("/uploads/default_avatar.png");

        userService.register(u);

        return "redirect:/login";
    }

    // 个人资料
    @GetMapping("/user/profile")
    public String profile(HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        User u = userService.findById(userId);
        model.addAttribute("user", u);
        return "profile";
    }

    // --- 新增：头像上传功能 ---
    @PostMapping("/user/uploadAvatar")
    public String uploadAvatar(@RequestParam("file") MultipartFile file,
                               HttpSession session,
                               HttpServletRequest request,
                               Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";

        // 1. 检查文件是否为空
        if (file.isEmpty()) {
            model.addAttribute("uploadError", "请选择文件");
            return profile(session, model);
        }

        // 2. 检查文件大小
        if (file.getSize() > MAX_AVATAR_SIZE) {
            model.addAttribute("uploadError", "文件过大，请上传2MB以内的图片");
            return profile(session, model);
        }

        // 3. 检查文件类型
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

            // 5. 生成新文件名 (UUID + 后缀)
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

    // 充值
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

    // 提现
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

    // 转账
    @PostMapping("/user/transfer")
    public String transfer(@RequestParam String toIdentifier, @RequestParam String amount, HttpSession session, Model model) {
        Long fromId = (Long) session.getAttribute("userId");
        if (fromId == null) return "redirect:/login";

        try {
            User toUser = userService.findByIdentifier(toIdentifier);
            if (toUser == null) {
                model.addAttribute("error", "接收方不存在");
                return profile(session, model);
            }
            userService.transfer(fromId, toUser.getId(), new BigDecimal(amount));
        } catch (Exception e) {
            model.addAttribute("error", "转账失败: " + e.getMessage());
            return profile(session, model);
        }
        return "redirect:/user/profile";
    }

    // 重置密码
    @GetMapping("/forgot")
    public String forgotPage() {
        return "forgot";
    }

    @PostMapping("/sendResetCode")
    @ResponseBody
    public String sendResetCode(@RequestParam String email) {
        User u = userService.findByEmail(email);
        if (u == null) return "no_user";

        try {
            String code = String.format("%06d", new Random().nextInt(999999));
            EmailCode ec = new EmailCode();
            ec.setEmail(email);
            ec.setCode(code);
            ec.setPurpose("reset");
            userService.saveEmailCode(ec);

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

    // 处理重置密码请求
    @PostMapping("/doReset")
    public String doReset(@RequestParam String email,
                          @RequestParam String code,
                          @RequestParam String newPassword,
                          Model model) {

        if (!userService.verifyEmailCode(email, "reset", code)) {
            model.addAttribute("error", "验证码错误或已过期");
            return "forgot";
        }

        try {
            userService.resetPassword(email, newPassword);
        } catch (Exception ex) {
            model.addAttribute("error", "重置失败：" + ex.getMessage());
            return "forgot";
        }

        return "redirect:/login";
    }


    // 注销账号页面
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

    // 发送注销账号验证码
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
            String code = String.format("%06d", new Random().nextInt(999999));
            EmailCode ec = new EmailCode();
            ec.setEmail(email);
            ec.setCode(code);
            ec.setPurpose(purpose);
            userService.saveEmailCode(ec);

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

    // 确认注销账号
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

        // 验证验证码
        if (!userService.verifyEmailCode(email, "delete_account", code)) {
            model.addAttribute("error", "验证码错误或已过期");
            model.addAttribute("user", user);
            return "deleteAccount";
        }

        try {
            // 尝试删除用户
            userService.deleteUser(userId);

            // 如果有头像文件，删除之（可选）
            if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
                String avatarPath = request.getServletContext().getRealPath(user.getAvatar());
                File avatarFile = new File(avatarPath);
                if (avatarFile.exists()) {
                    avatarFile.delete();
                }
            }

            // 清除session
            session.invalidate();

            return "redirect:/login";

        } catch (Exception e) {
            model.addAttribute("error", "注销失败: " + e.getMessage());
            model.addAttribute("user", user);
            return "deleteAccount";
        }
    }

}