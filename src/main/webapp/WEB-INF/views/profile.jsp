<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>个人资料 - 网上银行</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          crossorigin="anonymous">

    <style>
        body {
            background-color: #f8f9fa;
        }
        .profile-header {
            background-color: #fff;
            border-bottom: 1px solid #e9ecef;
            padding: 20px 0;
            margin-bottom: 20px;
        }
        .avatar {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 50%;
            border: 4px solid #007bff;
            box-shadow: 0 0 10px rgba(0, 123, 255, 0.2);
        }
        .balance-box {
            background-color: #28a745;
            color: white;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        .transaction-card {
            min-height: 200px;
        }
    </style>
</head>
<body>

<div class="container">

    <!-- 导航栏 -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white rounded shadow-sm my-3">
        <div class="container-fluid">
            <a class="navbar-brand text-primary fw-bold" href="${pageContext.request.contextPath}/index.jsp">🏦 网上银行</a>

            <div class="d-flex">
                <!-- 管理员入口 -->
                <c:if test="${user.isAdmin}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       class="btn btn-outline-success btn-sm me-2">
                        后台管理
                    </a>
                </c:if>

                <a href="${pageContext.request.contextPath}/logout"
                   class="btn btn-outline-danger btn-sm">
                    退出登录
                </a>
            </div>
        </div>
    </nav>

    <!-- 错误提示 -->
    <c:if test="${not empty error || not empty uploadError}">
        <div class="alert alert-danger">
            <c:if test="${not empty error}">错误: ${error}</c:if>
            <c:if test="${not empty uploadError}">上传头像失败: ${uploadError}</c:if>
        </div>
    </c:if>

    <!-- 成功提示 -->
    <c:if test="${not empty successMsg}">
        <div class="alert alert-success">${successMsg}</div>
    </c:if>

    <c:if test="${not empty user}">

        <!-- 个人资料头部 -->
        <div class="row profile-header bg-white rounded shadow-sm p-4 mb-4">

            <!-- 头像 -->
            <div class="col-md-3 text-center">

                <c:choose>
                    <c:when test="${not empty user.avatar}">
                        <img src="${pageContext.request.contextPath}${user.avatar}" class="avatar" alt="用户头像" />
                    </c:when>
                </c:choose>

                <!-- 上传头像 -->
                <form action="${pageContext.request.contextPath}/user/uploadAvatar"
                      method="post" enctype="multipart/form-data"
                      id="avatarUploadForm" class="mt-3">

                    <input type="file" name="file" id="avatarFile"
                           accept="image/*" style="display:none;"
                           onchange="document.getElementById('avatarUploadForm').submit();" />

                    <button type="button" class="btn btn-primary w-100"
                            onclick="document.getElementById('avatarFile').click();">
                        更换/上传头像
                    </button>

                    <small class="form-text text-muted">选择后会自动上传</small>
                </form>
            </div>

            <!-- 基本信息 -->
            <div class="col-md-5 d-flex flex-column justify-content-center">
                <h3 class="text-primary mb-3">${user.username} 的账户</h3>

                <c:if test="${not empty user.email}">
                    <p class="mb-1"><strong>邮箱:</strong> ${user.email}</p>
                </c:if>
            </div>

            <!-- 余额 -->
            <div class="col-md-4 d-flex align-items-center">
                <div class="balance-box w-100">
                    <small>当前账户余额 (CNY)</small>
                    <h1 class="display-5 fw-bold">¥ ${user.balance}</h1>
                </div>
            </div>
        </div>

        <!-- 三个操作卡片 -->
        <div class="row">

            <!-- 充值 -->
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm h-100 transaction-card">
                    <div class="card-header bg-primary text-white">📥 账户充值</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/user/recharge" method="post">
                            <label class="form-label">充值金额</label>
                            <input type="number" class="form-control" name="amount"
                                   placeholder="例如：100.00" min="0.01" step="0.01" required>
                            <button class="btn btn-primary mt-3 w-100">确认充值</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- 提现 -->
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm h-100 transaction-card">
                    <div class="card-header bg-primary text-white">📤 提现操作</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/user/withdraw" method="post">
                            <label class="form-label">提现金额</label>
                            <input type="number" class="form-control" name="amount"
                                   placeholder="例如：50.00" min="0.01" step="0.01" required>
                            <button class="btn btn-primary mt-3 w-100">确认提现</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- 转账 -->
            <div class="col-md-4 mb-4">
                <div class="card shadow-sm h-100 transaction-card">
                    <div class="card-header bg-primary text-white">💸 账户转账</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/user/transfer" method="post">
                            <label class="form-label">接收方（用户名或邮箱）</label>
                            <input type="text" class="form-control" name="toIdentifier" required>

                            <label class="form-label mt-3">转账金额</label>
                            <input type="number" class="form-control" name="amount"
                                   min="0.01" step="0.01" required>

                            <button class="btn btn-primary mt-3 w-100">确认转账</button>
                        </form>
                    </div>
                </div>
            </div>

        </div>

        <!-- 注销 -->
        <div class="row my-4">
            <div class="col-12 text-center">
                <a href="${pageContext.request.contextPath}/user/deleteAccount"
                   class="btn btn-link text-danger">
                    🗑 注销账号
                </a>
            </div>
        </div>

    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        crossorigin="anonymous"></script>
</body>
</html>
