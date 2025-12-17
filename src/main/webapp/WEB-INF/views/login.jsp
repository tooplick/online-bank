<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>登录 - 极简银行</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <script src="https://unpkg.com/lucide@latest"></script>
  <style>
    :root { --accent: #475569; --text: #1e293b; --soft-bg: #f1f5f9; }
    body, html { height: 100%; margin: 0; font-family: 'Inter', sans-serif; }
    .full-screen { display: flex; height: 100vh; width: 100vw; overflow: hidden; }

    .brand-side {
      flex: 1.2; background: var(--accent); color: white;
      display: flex; flex-direction: column; justify-content: center; padding: 10%;
    }
    .form-side {
      flex: 1; background: white; display: flex; flex-direction: column;
      justify-content: center; align-items: center; padding: 5%;
    }

    .form-container { width: 100%; max-width: 360px; }
    .input-group-custom { border-bottom: 2px solid #e2e8f0; margin-bottom: 2rem; position: relative; }
    .input-group-custom input {
      border: none; width: 100%; padding: 10px 0; outline: none; font-size: 1rem;
    }
    .btn-minimal {
      background: var(--accent); color: white; border-radius: 8px;
      padding: 12px; font-weight: 600; width: 100%; transition: 0.3s;
    }
    .btn-minimal:hover { background: #334155; transform: translateY(-2px); }
  </style>
</head>
<body>
<div class="full-screen">
  <div class="brand-side d-none d-lg-flex">
    <h1 class="display-3 fw-bold">ONLINE<br/>BANK.</h1>
  </div>
  <div class="form-side">
    <div class="form-container">
      <h2 class="fw-bold mb-5">欢迎回来</h2>

      <c:if test="${not empty error}">
        <div class="alert alert-light text-danger border-0 p-0 mb-4 small">! ${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/doLogin" method="post">
        <div class="input-group-custom">
          <input type="text" name="identifier" placeholder="用户名或邮箱" required />
        </div>
        <div class="input-group-custom">
          <input type="password" name="password" placeholder="密码" required />
        </div>
        <button type="submit" class="btn btn-minimal shadow-sm mt-4">进入系统</button>
      </form>

      <div class="mt-5 d-flex justify-content-between small">
        <a href="${pageContext.request.contextPath}/register" class="text-secondary text-decoration-none">注册账号</a>
        <a href="${pageContext.request.contextPath}/forgot" class="text-muted text-decoration-none">忘记密码?</a>
      </div>
    </div>
  </div>
</div>
<script>lucide.createIcons();</script>
</body>
</html>