<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>登录 - 网上银行</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
        crossorigin="anonymous">
  <style>
    /* 自定义样式：美化背景并居中登录卡片 */
    body {
      background-color: #f0f2f5; /* 柔和的浅灰色背景 */
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
    }
    .login-card {
      max-width: 400px;
      width: 90%;
      padding: 2rem;
      box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
      border-radius: 0.75rem;
    }
    .form-label {
      font-weight: 500;
    }
    .btn-primary {
      background-color: #007bff; /* 银行常用的蓝色调 */
      border-color: #007bff;
    }
  </style>
</head>
<body>

<div class="card login-card">
  <div class="card-body">
    <h3 class="card-title text-center mb-4 text-primary">网上银行登录</h3>

    <c:if test="${not empty error}">
      <div class="alert alert-danger text-center" role="alert">
          ${error}
      </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/doLogin" method="post">

      <div class="mb-3">
        <label for="identifier" class="form-label">用户名或邮箱</label>
        <input type="text"
               class="form-control"
               id="identifier"
               name="identifier"
               placeholder="请输入用户名或邮箱"
               required/>
      </div>

      <div class="mb-4">
        <label for="password" class="form-label">密码</label>
        <input type="password"
               class="form-control"
               id="password"
               name="password"
               placeholder="请输入密码"
               required/>
      </div>

      <div class="d-grid gap-2">
        <button type="submit" class="btn btn-primary btn-lg">登录</button>
      </div>
    </form>

    <hr class="my-4">

    <p class="text-center">
      还没有账户？<a href="${pageContext.request.contextPath}/register" class="text-decoration-none">立即注册</a>
    </p>
    <p class="text-center">
      <a href="${pageContext.request.contextPath}/forgot" class="text-decoration-none text-muted">忘记密码?</a>
    </p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
</body>
</html>