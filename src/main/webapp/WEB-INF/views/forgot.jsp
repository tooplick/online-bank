<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>忘记密码 - 网上银行</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
        crossorigin="anonymous">
  <style>
    /* 自定义样式：美化背景并居中卡片 */
    body {
      background-color: #f0f2f5; /* 柔和的浅灰色背景 */
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
    }
    .forgot-card {
      max-width: 450px;
      width: 90%;
      padding: 2rem;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      border-radius: 0.75rem;
      /* 确保卡片在消息弹窗下层 */
      position: relative;
      z-index: 1;
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


    function sendReset() {
      var emailInput = document.getElementById('email');
      var email = emailInput.value.trim();
      var sendBtn = document.getElementById('sendCodeBtn');

      if (!email || !/\S+@\S+\.\S/.test(email)) {
        showTopAlert('请输入有效的邮箱地址', 'warning');
        return;
      }

      // 禁用按钮并启动计时器
      sendBtn.disabled = true;
      if (timer) clearInterval(timer);

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
      // 注意：这里使用了您原有的 URL /sendResetCode
      xhr.open('POST', '${pageContext.request.contextPath}/sendResetCode', true);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
          if (xhr.status === 200) {
            // *** 验证码发送成功：使用顶部弹窗提示 ***
            showTopAlert('✅ 验证码已发送到您的邮箱，请查收！', 'success');
          } else {
            // *** 验证码发送失败：使用顶部弹窗提示并恢复按钮 ***
            showTopAlert('❌ 发送请求失败，请检查邮箱地址或稍后重试。', 'danger', 6000);

            // 失败后立即停止计时器并恢复按钮
            if(timer) clearInterval(timer);
            sendBtn.innerHTML = '发送验证码';
            sendBtn.disabled = false;
            countdown = 60;
          }
        }
      };
      xhr.send('email=' + encodeURIComponent(email));
    }

    // 新增：前端密码一致性检查
    function checkPasswordMatch() {
      var newPassword = document.getElementById('newPassword').value;
      var confirmNewPassword = document.getElementById('confirmNewPassword').value;

      if (newPassword !== confirmNewPassword) {
        showTopAlert('⚠️ 两次输入的新密码不一致！请重新输入。', 'warning');
        return false;
      }
      return true;
    }
  </script>
</head>
<body>

<div id="top-alert-container">
  <div id="top-alert" role="alert">
  </div>
</div>

<div class="card forgot-card">
  <div class="card-body">
    <h3 class="card-title text-center mb-4 text-warning">忘记密码</h3>
    <p class="text-center text-muted">通过邮箱验证码重置您的账户密码。</p>

    <c:if test="${not empty error}">
      <div class="alert alert-danger text-center" role="alert">
          ${error}
      </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/doReset" method="post" onsubmit="return checkPasswordMatch()">

      <div class="mb-3">
        <label for="email" class="form-label">注册邮箱</label>
        <div class="input-group">
          <input type="email"
                 class="form-control"
                 id="email"
                 name="email"
                 placeholder="请输入您的注册邮箱"
                 required/>
          <button class="btn btn-outline-warning"
                  type="button"
                  id="sendCodeBtn"
                  onclick="sendReset();">
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
               placeholder="请输入收到的验证码"
               required/>
      </div>

      <div class="mb-3">
        <label for="newPassword" class="form-label">新密码</label>
        <input type="password"
               class="form-control"
               id="newPassword"
               name="newPassword"
               placeholder="设置您的新密码"
               required/>
      </div>

      <div class="mb-4">
        <label for="confirmNewPassword" class="form-label">确认新密码</label>
        <input type="password"
               class="form-control"
               id="confirmNewPassword"
               name="confirmNewPassword"
               placeholder="请再次输入新密码"
               required/>
      </div>

      <div class="d-grid gap-2">
        <button type="submit" class="btn btn-warning btn-lg">重置密码</button>
      </div>
    </form>

    <hr class="my-4">

    <p class="text-center">
      <a href="${pageContext.request.contextPath}/login" class="text-decoration-none">返回登录页</a>
    </p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
</body>
</html>