<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>注册 - 网上银行</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
        crossorigin="anonymous">
  <style>
    /* 自定义样式：美化背景并居中注册卡片 */
    body {
      background-color: #e9ecef; /* 浅灰色背景 */
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
    }
    .register-card {
      max-width: 500px;
      width: 90%;
      padding: 2rem;
      box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
      border-radius: 0.75rem;
      /* 确保卡片在消息弹窗下层 */
      position: relative;
      z-index: 1;
    }
    .form-label {
      font-weight: 500;
    }
    /* 顶部消息弹窗样式 */
    #top-alert-container {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      z-index: 1050; /* 确保在最上层 */
      padding: 10px;
      display: none; /* 默认隐藏 */
    }
    #top-alert-container .alert {
      margin-bottom: 0;
      box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    }
  </style>

  <script>
    // 计时器变量
    var countdown = 60;
    var timer = null;

    // 显示顶部弹窗的函数
    function showTopAlert(message, type = 'success', duration = 4000) {
      var container = document.getElementById('top-alert-container');
      var alertDiv = document.getElementById('top-alert');

      // 设置消息内容和类型
      alertDiv.className = 'alert alert-' + type + ' text-center';
      alertDiv.innerHTML = message;

      // 显示容器
      container.style.display = 'block';

      // 自动隐藏
      setTimeout(function() {
        container.style.display = 'none';
      }, duration);
    }

    function sendCode() {
      var emailInput = document.getElementById('email');
      var email = emailInput.value.trim();

      // 简单前端校验
      if (!email || !/\S+@\S+\.\S/.test(email)) {
        showTopAlert('请输入有效的邮箱地址', 'warning');
        return;
      }

      // 禁用按钮并启动计时器
      var sendBtn = document.getElementById('sendCodeBtn');
      sendBtn.disabled = true;

      // 检查并清理旧的计时器
      if (timer) {
        clearInterval(timer);
        countdown = 60; // 重置计时，防止重复点击导致异常
      }

      timer = setInterval(function() {
        countdown--;
        if (countdown === 0) {
          clearInterval(timer);
          sendBtn.innerHTML = '发送验证码';
          sendBtn.disabled = false;
          countdown = 60; // 重置计时
        } else {
          sendBtn.innerHTML = countdown + 's 后重试';
        }
      }, 1000);

      // 发送 AJAX 请求
      var xhr = new XMLHttpRequest();
      xhr.open('POST', '${pageContext.request.contextPath}/sendCode', true);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
          if (xhr.status === 200) {
            if (xhr.responseText.trim() === 'sent') {
              // *** 验证码发送成功：使用顶部弹窗提示 ***
              showTopAlert('✅ 验证码已发送，请检查您的邮箱（包括垃圾邮件箱）', 'success');
            } else if (xhr.responseText.trim() === 'send_fail') {
              // *** 验证码发送失败：使用顶部弹窗提示并恢复按钮 ***
              showTopAlert('❌ 发送失败：邮件服务器错误或邮箱不存在', 'danger', 6000);
              // 失败后立即停止计时器并恢复按钮
              if(timer) clearInterval(timer);
              sendBtn.innerHTML = '发送验证码';
              sendBtn.disabled = false;
              countdown = 60;
            } else {
              // 其他错误提示
              showTopAlert('发送结果：' + xhr.responseText.trim(), 'warning');
            }
          } else {
            // 请求失败提示
            showTopAlert('请求失败，状态：' + xhr.status, 'danger');
            // 失败后立即停止计时器并恢复按钮
            if(timer) clearInterval(timer);
            sendBtn.innerHTML = '发送验证码';
            sendBtn.disabled = false;
            countdown = 60;
          }
        }
      };
      xhr.send('email=' + encodeURIComponent(email) + '&purpose=register');
    }
  </script>
</head>
<body>

<div id="top-alert-container">
  <div id="top-alert" role="alert">
  </div>
</div>

<div class="card register-card">
  <div class="card-body">
    <h3 class="card-title text-center mb-4 text-success">新用户注册</h3>
    <p class="text-center text-muted">请填写以下信息以创建您的银行账户</p>

    <c:if test="${not empty error}">
      <div class="alert alert-danger text-center" role="alert">
          ${error}
      </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/doRegister" method="post">

      <div class="mb-3">
        <label for="email" class="form-label">邮箱</label>
        <div class="input-group">
          <input type="email"
                 class="form-control"
                 id="email"
                 name="email"
                 placeholder="请输入常用邮箱"
                 required/>
          <button class="btn btn-outline-secondary"
                  type="button"
                  id="sendCodeBtn"
                  onclick="sendCode();">
            发送验证码
          </button>
        </div>
      </div>

      <div class="mb-3">
        <label for="code" class="form-label">验证码</label>
        <input type="text"
               class="form-control"
               id="code"
               name="code"
               placeholder="请输入收到的6位验证码"
               required/>
      </div>

      <div class="mb-3">
        <label for="username" class="form-label">用户名</label>
        <input type="text"
               class="form-control"
               id="username"
               name="username"
               placeholder="账户昵称"
               required/>
      </div>

      <div class="mb-4">
        <label for="password" class="form-label">密码</label>
        <input type="password"
               class="form-control"
               id="password"
               name="password"
               placeholder="设置登录密码"
               required/>
      </div>

      <div class="d-grid gap-2">
        <button type="submit" class="btn btn-success btn-lg">立即注册</button>
      </div>
    </form>

    <hr class="my-4">

    <p class="text-center">
      已有账户？<a href="${pageContext.request.contextPath}/login" class="text-decoration-none">去登录</a>
    </p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
</body>
</html>