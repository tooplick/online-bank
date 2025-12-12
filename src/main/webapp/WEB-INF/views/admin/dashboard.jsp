<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理员面板 - 网上银行</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            background-color: #1976d2;
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .admin-nav {
            background-color: white;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .nav-link {
            margin-right: 20px;
            text-decoration: none;
            color: #1976d2;
            font-weight: bold;
        }

        .nav-link:hover {
            color: #0d47a1;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background-color: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .stat-card h3 {
            margin-top: 0;
            color: #555;
            font-size: 16px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: #1976d2;
        }

        .quick-actions {
            background-color: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .action-btn {
            display: inline-block;
            background-color: #1976d2;
            color: white;
            padding: 10px 20px;
            margin-right: 10px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: bold;
        }

        .action-btn:hover {
            background-color: #0d47a1;
        }

        .danger-btn {
            background-color: #d32f2f;
        }

        .danger-btn:hover {
            background-color: #b71c1c;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>管理员面板</h1>
        <p>欢迎回来，${admin.username}</p>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <h3>系统用户总数</h3>
            <div class="stat-value">${totalUsers} 人</div>
        </div>

        <div class="stat-card">
            <h3>系统总余额</h3>
            <div class="stat-value">¥ ${totalBalance}</div>
        </div>

        <div class="stat-card">
            <h3>当前管理员</h3>
            <div class="stat-value">${admin.username}</div>
        </div>
    </div>

    <div class="quick-actions">
        <h3>快捷操作</h3>
        <a href="${pageContext.request.contextPath}/admin/users" class="action-btn">管理用户</a>
        <a href="${pageContext.request.contextPath}/user/profile" class="action-btn">个人中心</a>
    </div>
</div>
</body>
</html>