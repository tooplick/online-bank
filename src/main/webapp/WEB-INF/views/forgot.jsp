<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>重置密码 - 极简银行</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&display=swap" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>

  <style>
    :root {
      --primary-black: #121212;
      --accent-blue: #0052ff;
      --muted-gray: #999;
      --border-light: #eee;
    }

    body, html {
      height: 100%;
      margin: 0;
      font-family: 'Noto Sans SC', sans-serif;
      background-color: #ffffff;
      color: var(--primary-black);
    }

    .viewport-wrapper {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }

    .form-section {
      width: 100%;
      max-width: 360px;
    }

    .brand-title {
      font-size: 2rem;
      font-weight: 700;
      letter-spacing: -1px;
      margin-bottom: 0.5rem;
    }

    .brand-subtitle {
      font-size: 0.9rem;
      color: var(--muted-gray);
      margin-bottom: 3rem;
    }

    /* 极简下划线输入框 */
    .form-group-custom {
      margin-bottom: 1.8rem;
      position: relative;
    }

    .form-label-custom {
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--muted-gray);
      display: block;
      margin-bottom: 4px;
    }

    .input-underlined {
      width: 100%;
      border: none;
      border-bottom: 1px solid var(--border-light);
      border-radius: 0;
      padding: 10px 0;
      font-size: 1rem;
      background: transparent;
      transition: border-color 0.3s ease;
    }

    .input-underlined:focus {
      outline: none;
      border-bottom-color: var(--primary-black);
    }

    /* 文字链接式发送按钮 */
    .btn-send-text {
      position: absolute;
      right: 0;
      bottom: 10px;
      background: none;
      border: none;
      color: var(--accent-blue);
      font-weight: 600;
      font-size: 0.85rem;
      cursor: pointer;
      padding: 0;
    }

    .btn-send-text:disabled {
      color: var(--muted-gray);
      cursor: not-allowed;
    }

    /* 纯黑块状提交按钮 */
    .btn-submit {
      width: 100%;
      background: var(--primary-black);
      color: white;
      border: none;
      padding: 14px;
      border-radius: 4px;
      font-weight: 600;
      margin-top: 1rem;
      transition: opacity 0.2s;
    }

    .btn-submit:hover {
      opacity: 0.85;
    }

    /* 底部状态提示胶囊 */
    #status-toast {
      position: fixed;
      bottom: 30px;
      left: 50%;
      transform: translateX(-50%);
      background: var(--primary-black);
      color: white;
      padding: 10px 24px;
      border-radius: 100px;
      font-size: 0.85rem;
      z-index: 9999;
      display: none;
      box-shadow: 0 10px 20px rgba(0,0,0,0.1);
    }

    footer {
      margin-top: 3rem;
      padding-top: 2rem;
      border-top: 1px solid var(--border-light);
    }
  </style>
</head>
<body>

<div id="status-toast"></div>

<div class="viewport-wrapper">
  <main class="form-section">
    <header>
      <h1 class="brand-title">找回密码</h1>
      <p class="brand-subtitle">验证您的身份并设置新的安全密码。</p>
    </header>

    <form action="${pageContext.request.contextPath}/doReset" method="post" onsubmit="return checkPasswordMatch()">

      <div class="form-group-custom">
        <label class="form-label-custom">注册邮箱</label>
        <input type="email" class="input-underlined" id="email" name="email" placeholder="example@mail.com" required>
        <button type="button" class="btn-send-text" id="sendCodeBtn" onclick="sendReset()">获取验证码</button>
      </div>

      <div class="form-group-custom">
        <label class="form-label-custom">验证码</label>
        <input type="text" class="input-underlined" id="code" name="code" placeholder="6位数字" required>
      </div>

      <div class="form-group-custom">
        <label class="form-label-custom">设置新密码</label>
        <input type="password" class="input-underlined" id="newPassword" name="newPassword" placeholder="至少6位字符" required>
      </div>

      <div class="form-group-custom">
        <label class="form-label-custom">确认新密码</label>
        <input type="password" class="input-underlined" id="confirmNewPassword" name="confirmNewPassword" placeholder="再次输入新密码" required>
      </div>

      <button type="submit" class="btn-submit">重置密码</button>
    </form>

    <footer>
      <p class="small">
        想起密码了？ <a href="${pageContext.request.contextPath}/login" class="text-dark fw-bold text-decoration-none">立即登录</a>
      </p>
    </footer>
  </main>
</div>

<script>
  lucide.createIcons();

  var countdown = 60, timer = null;

  function showStatus(msg, isError = false) {
    const toast = document.getElementById('status-toast');
    toast.innerText = msg;
    toast.style.backgroundColor = isError ? '#ff3b30' : '#121212';
    toast.style.display = 'block';
    setTimeout(() => { toast.style.display = 'none'; }, 4000);
  }

  function sendReset() {
    var email = document.getElementById('email').value.trim();
    if (!email || !/\S+@\S+\.\S+/.test(email)) {
      showStatus('请输入有效的邮箱', true);
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
    xhr.open('POST', '${pageContext.request.contextPath}/sendResetCode', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          showStatus('验证码已发送');
        } else {
          showStatus('发送失败，请稍后重试', true);
          clearInterval(timer);
          btn.innerText = '获取验证码';
          btn.disabled = false;
        }
      }
    };
    xhr.send('email=' + encodeURIComponent(email));
  }

  function checkPasswordMatch() {
    var p1 = document.getElementById('newPassword').value;
    var p2 = document.getElementById('confirmNewPassword').value;
    if (p1 !== p2) {
      showStatus('两次输入的密码不一致', true);
      return false;
    }
    return true;
  }

  // 后端错误注入提示
  <c:if test="${not empty error}">
  showStatus('${error}', true);
  </c:if>
</script>

</body>
</html>