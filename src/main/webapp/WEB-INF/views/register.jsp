<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>注册 - 网上银行</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&display=swap" rel="stylesheet">

  <style>
    :root {
      --primary-black: #121212;
      --accent-blue: #0052ff;
      --soft-gray: #f2f2f2;
    }

    body, html {
      height: 100%;
      margin: 0;
      font-family: 'Noto Sans SC', sans-serif;
      background-color: #ffffff; /* 纯白背景 */
      color: var(--primary-black);
    }

    /* 全屏居中容器 */
    .viewport-wrapper {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }

    .form-section {
      width: 100%;
      max-width: 360px; /* 窄版布局，更显精致 */
    }

    /* 标题设计：大字号、加粗、左对齐 */
    .brand-title {
      font-size: 2rem;
      font-weight: 700;
      letter-spacing: -1px;
      margin-bottom: 0.5rem;
    }

    .brand-subtitle {
      font-size: 0.9rem;
      color: #666;
      margin-bottom: 2.5rem;
    }

    /* 输入框去边框化设计 */
    .form-group-custom {
      margin-bottom: 1.5rem;
      position: relative;
    }

    .form-control-custom {
      width: 100%;
      border: none;
      border-bottom: 2px solid var(--soft-gray);
      border-radius: 0;
      padding: 12px 0;
      font-size: 1rem;
      background: transparent;
      transition: border-color 0.3s ease;
    }

    .form-control-custom:focus {
      outline: none;
      border-bottom-color: var(--primary-black);
    }

    .form-label-custom {
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: #999;
      display: block;
      margin-bottom: 4px;
    }

    /* 验证码按钮：文字链接形式 */
    .btn-send-text {
      position: absolute;
      right: 0;
      bottom: 12px;
      background: none;
      border: none;
      color: var(--accent-blue);
      font-weight: 500;
      font-size: 0.85rem;
      cursor: pointer;
      padding: 0;
    }

    .btn-send-text:disabled {
      color: #ccc;
    }

    /* 提交按钮：深色块状 */
    .btn-submit {
      width: 100%;
      background: var(--primary-black);
      color: white;
      border: none;
      padding: 14px;
      border-radius: 4px;
      font-weight: 500;
      margin-top: 1.5rem;
      transition: opacity 0.2s;
    }

    .btn-submit:hover {
      opacity: 0.85;
    }

    /* 顶部消息提示：简洁横条 */
    #top-alert-container {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      z-index: 9999;
      display: none;
    }

    .minimal-alert {
      padding: 12px;
      text-align: center;
      font-size: 0.9rem;
      font-weight: 500;
    }
  </style>
</head>
<body>

<div id="top-alert-container">
  <div id="top-alert" class="minimal-alert"></div>
</div>

<div class="viewport-wrapper">
  <main class="form-section">
    <header>
      <h1 class="brand-title">注册</h1>
    </header>

    <c:if test="${not empty error}">
      <div class="text-danger small mb-3">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/doRegister" method="post">
      <div class="form-group-custom">
        <label class="form-label-custom">邮箱地址</label>
        <input type="email" class="form-control-custom" id="email" name="email" placeholder="example@mail.com" required>
        <button type="button" class="btn-send-text" id="sendCodeBtn" onclick="sendCode()">获取验证码</button>
      </div>

      <div class="form-group-custom">
        <label class="form-label-custom">验证码</label>
        <input type="text" class="form-control-custom" id="code" name="code" placeholder="输入6位代码" required>
      </div>

      <div class="form-group-custom">
        <label class="form-label-custom">用户名</label>
        <input type="text" class="form-control-custom" id="username" name="username" placeholder="设置你的昵称" required>
      </div>

      <div class="form-group-custom">
        <label class="form-label-custom">设置密码</label>
        <input type="password" class="form-control-custom" id="password" name="password" placeholder="••••••" required>
      </div>

      <button type="submit" class="btn-submit">创建账户</button>
    </form>

    <footer class="mt-5 pt-4" style="border-top: 1px solid #eee;">
      <p class="small text-muted">
        已有账户？ <a href="${pageContext.request.contextPath}/login" class="text-dark fw-bold text-decoration-none">登录</a>
      </p>
    </footer>
  </main>
</div>

<script>
  var countdown = 60, timer = null;

  function showTopAlert(msg, type = 'dark') {
    var wrap = document.getElementById('top-alert-container');
    var alertDiv = document.getElementById('top-alert');

    // 映射颜色
    const bg = type === 'danger' ? '#ff3b30' : (type === 'warning' ? '#ffcc00' : '#121212');
    alertDiv.style.backgroundColor = bg;
    alertDiv.style.color = '#fff';
    alertDiv.innerHTML = msg;

    wrap.style.display = 'block';
    setTimeout(() => { wrap.style.display = 'none'; }, 4000);
  }

  function sendCode() {
    var email = document.getElementById('email').value.trim();
    if (!email || !/\S+@\S+\.\S+/.test(email)) {
      showTopAlert('请输入有效的邮箱', 'danger');
      return;
    }

    var btn = document.getElementById('sendCodeBtn');
    btn.disabled = true;

    timer = setInterval(() => {
      countdown--;
      if (countdown <= 0) {
        clearInterval(timer);
        btn.innerText = '获取验证码';
        btn.disabled = false;
        countdown = 60;
      } else {
        btn.innerText = countdown + 's';
      }
    }, 1000);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/sendCode', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4 && xhr.status === 200) {
        var res = xhr.responseText.trim();
        if (res === 'sent') showTopAlert('验证码已发送');
        else if (res === 'email_registered') {
          showTopAlert('此邮箱已被注册', 'danger');
          clearInterval(timer); btn.innerText = '获取验证码'; btn.disabled = false;
        } else {
          showTopAlert('发送失败', 'danger');
        }
      }
    };
    xhr.send('email=' + encodeURIComponent(email) + '&purpose=register');
  }
</script>

</body>
</html>