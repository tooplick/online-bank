<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>账户概览 - 网上银行</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        :root {
            --bg-body: #f5f7f9;
            --text-main: #2c3e50;
            --text-muted: #7f8c8d;
            --accent-dark: #34495e; /* 深蓝灰色，低饱和度 */
            --card-border: #e1e8ed;
        }

        body {
            background-color: var(--bg-body);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            color: var(--text-main);
        }

        /* 顶部导航 */
        .navbar-custom {
            padding: 1rem 2rem;
            background: transparent;
        }

        .navbar-brand {
            font-weight: 700;
            color: var(--accent-dark) !important;
            letter-spacing: -0.5px;
        }

        .main-container {
            max-width: 1140px;
            margin: 0 auto;
            padding: 0 1.5rem 4rem 1.5rem;
        }

        /* 欢迎区块：缩小尺寸，降低颜色饱和度 */
        .welcome-section {
            background-color: var(--accent-dark);
            background-image: linear-gradient(135deg, #34495e 0%, #2c3e50 100%);
            border-radius: 20px;
            padding: 2rem; /* 缩小内边距 */
            color: #ecf0f1;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            margin-bottom: 2rem;
        }

        /* 头像设计：改为圆形 */
        .avatar-container {
            position: relative;
            display: inline-block;
        }

        .avatar-img {
            width: 90px; /* 略微缩小 */
            height: 90px;
            border-radius: 50%; /* 圆形 */
            object-fit: cover;
            border: 3px solid rgba(255, 255, 255, 0.15);
        }

        .upload-badge {
            position: absolute;
            bottom: 0;
            right: 0;
            background: #fff;
            color: var(--accent-dark);
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            font-size: 0.8rem;
        }

        /* 功能卡片：简洁边框线风格 */
        .action-card {
            background: white;
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 1.5rem;
            height: 100%;
            transition: all 0.2s ease;
        }

        .action-card:hover {
            border-color: #bdc3c7;
            transform: translateY(-3px);
        }

        .icon-box {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.2rem;
            background-color: #f8f9fa;
            color: var(--accent-dark);
            font-size: 1.1rem;
        }

        .form-control-custom {
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 0.6rem 1rem;
            font-size: 0.95rem;
            outline: none;
        }

        .btn-custom {
            border-radius: 10px;
            padding: 0.7rem;
            font-weight: 600;
            background-color: var(--accent-dark);
            border: none;
            color: white;
            width: 100%;
            margin-top: 1rem;
        }

        .btn-custom:hover {
            background-color: #2c3e50;
            color: white;
        }

        /* 管理员入口 */
        .admin-link {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--accent-dark);
            text-decoration: none;
            background: #fff;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            border: 1px solid var(--card-border);
        }
    </style>
</head>
<body>

<nav class="navbar navbar-custom">
    <div class="container-fluid">
        <a class="navbar-brand" href="#"><i class="fas fa-shield-halved me-2"></i>ONLINEBANK</a>

        <div class="d-flex align-items-center gap-3">
            <c:if test="${user.isAdmin}">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-link">
                    后台管理
                </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/logout" class="text-muted small text-decoration-none">
                退出登录
            </a>
        </div>
    </div>
</nav>

<div class="main-container">

    <c:if test="${not empty error || not empty uploadError}">
        <div class="alert alert-light border shadow-sm small py-2 rounded-3 mb-4">
            <i class="fas fa-info-circle text-danger me-2"></i> ${error} ${uploadError}
        </div>
    </c:if>

    <c:if test="${not empty user}">
        <div class="welcome-section">
            <div class="row align-items-center g-3">
                <div class="col-md-auto">
                    <div class="avatar-container">
                        <img src="${pageContext.request.contextPath}${empty user.avatar ? '/uploads/default_avatar.png' : user.avatar}"
                             class="avatar-img" alt="avatar"
                             onerror="this.src='${pageContext.request.contextPath}/uploads/default_avatar.png'">

                        <form action="${pageContext.request.contextPath}/user/uploadAvatar" method="post" enctype="multipart/form-data" id="avatarForm">
                            <input type="file" name="file" id="avatarFile" style="display:none" onchange="document.getElementById('avatarForm').submit()">
                            <label for="avatarFile" class="upload-badge">
                                <i class="fas fa-camera"></i>
                            </label>
                        </form>
                    </div>
                </div>
                <div class="col-md ps-md-3">
                    <h5 class="opacity-75 mb-1 small fw-normal">账户持有者：${user.username}</h5>
                    <h4 class="fw-bold mb-2">资产管理概览</h4>
                    <c:if test="${not empty user.email}">
                        <p class="mb-0 small opacity-50"><i class="far fa-envelope me-2"></i>${user.email}</p>
                    </c:if>
                </div>
                <div class="col-md-auto text-md-end ms-auto">
                    <span class="small opacity-50 text-uppercase d-block mb-1">当前余额</span>
                    <h2 class="fw-bold mb-0">¥ ${user.balance}</h2>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="action-card">
                    <div class="icon-box">
                        <i class="fas fa-plus"></i>
                    </div>
                    <h6 class="fw-bold mb-3">充值存款</h6>
                    <form action="${pageContext.request.contextPath}/user/recharge" method="post">
                        <input type="number" class="form-control-custom w-100" name="amount" placeholder="存入金额" min="0.01" step="0.01" required>
                        <button class="btn btn-custom">确认存入</button>
                    </form>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="action-card">
                    <div class="icon-box">
                        <i class="fas fa-minus"></i>
                    </div>
                    <h6 class="fw-bold mb-3">资金提现</h6>
                    <form action="${pageContext.request.contextPath}/user/withdraw" method="post">
                        <input type="number" class="form-control-custom w-100" name="amount" placeholder="提取金额" min="0.01" step="0.01" required>
                        <button class="btn btn-custom">确认提取</button>
                    </form>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="action-card">
                    <div class="icon-box">
                        <i class="fas fa-exchange-alt"></i>
                    </div>
                    <h6 class="fw-bold mb-3">安全转账</h6>
                    <form action="${pageContext.request.contextPath}/user/transfer" method="post">
                        <div class="mb-2">
                            <input type="text" class="form-control-custom w-100" name="toIdentifier" placeholder="接收人账号" required>
                        </div>
                        <input type="number" class="form-control-custom w-100" name="amount" placeholder="金额" min="0.01" step="0.01" required>
                        <button class="btn btn-custom">立即转账</button>
                    </form>
                </div>
            </div>
        </div>

        <div class="mt-5 text-center">
            <a href="${pageContext.request.contextPath}/user/deleteAccount" class="text-muted small text-decoration-none">
                注销账号
            </a>
        </div>
    </c:if>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>