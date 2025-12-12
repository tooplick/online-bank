<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户管理 - 网上银行</title>

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

        .user-table {
            width: 100%;
            background-color: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            table-layout: fixed;
        }

        .user-table th,
        .user-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .user-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
        }

        .user-table tr:hover {
            background-color: #f5f5f5;
        }

        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            margin: 2px;
        }

        .btn-primary { background-color: #1976d2; color: white; }
        .btn-primary:hover { background-color: #0d47a1; }

        .btn-danger { background-color: #d32f2f; color: white; }
        .btn-danger:hover { background-color: #b71c1c; }

        .btn-warning { background-color: #ff9800; color: white; }
        .btn-warning:hover { background-color: #f57c00; }

        .admin-badge {
            background-color: #4caf50;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }

        .balance-input {
            width: 100px;
            padding: 4px;
            margin-right: 5px;
        }

        .operation-select {
            padding: 4px;
            margin-right: 5px;
        }

        .actions-container {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group {
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .user-table td:last-child {
            white-space: normal;
            overflow: visible;
        }

        @media (max-width: 1200px) {
            .form-group {
                flex-wrap: wrap;
            }
        }

        /* 顶部弹窗（Toast） */
        .toast {
            position: fixed;
            top: -60px;
            left: 50%;
            transform: translateX(-50%);
            background-color: #323232;
            color: white;
            padding: 12px 20px;
            border-radius: 6px;
            opacity: 0;
            transition: all 0.4s ease;
            z-index: 9999;
            font-size: 15px;
        }

        .toast.show {
            top: 20px;
            opacity: 1;
        }

    </style>

    <script>
        /* 顶部弹窗函数 */
        function showToast(message) {
            const toast = document.getElementById('toast');
            toast.innerText = message;
            toast.classList.add('show');

            setTimeout(() => {
                toast.classList.remove('show');
            }, 2000);
        }

        function confirmDelete(userId, username) {
            if (confirm('确定要删除用户 "' + username + '" 吗？此操作不可恢复！')) {
                deleteUser(userId);
            }
        }

        function deleteUser(userId) {
            fetch('${pageContext.request.contextPath}/admin/deleteUser?userId=' + userId, {
                method: 'POST'
            })
                .then(response => response.text())
                .then(result => {
                    if (result === 'success') {
                        showToast('用户删除成功！');
                        setTimeout(() => location.reload(), 1200);
                    } else if (result === 'cannot_delete_self') {
                        showToast('不能删除自己！');
                    } else if (result === 'not_admin') {
                        showToast('没有管理员权限！');
                    } else if (result === 'user_not_found') {
                        showToast('用户不存在！');
                    } else {
                        showToast('删除失败: ' + result);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showToast('删除失败，请稍后重试');
                });
        }

        function adjustBalance(userId) {
            const amount = document.getElementById('amount_' + userId).value;
            const operation = document.getElementById('operation_' + userId).value;

            if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
                showToast('请输入有效的金额');
                return;
            }

            fetch('${pageContext.request.contextPath}/admin/adjustBalance?userId=' + userId +
                '&amount=' + amount + '&operation=' + operation, {
                method: 'POST'
            })
                .then(response => response.text())
                .then(result => {
                    if (result === 'success') {
                        showToast('余额调整成功！');
                        setTimeout(() => location.reload(), 1200);
                    } else if (result === 'insufficient_balance') {
                        showToast('用户余额不足！');
                    } else if (result === 'not_admin') {
                        showToast('没有管理员权限！');
                    } else {
                        showToast('调整失败: ' + result);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showToast('调整失败，请稍后重试');
                });
        }

    </script>
</head>

<body>

<!-- 顶部弹窗 -->
<div id="toast" class="toast"></div>

<div class="container">
    <div class="header">
        <h1>用户管理</h1>
        <p>管理员: ${admin.username}</p>
    </div>

    <div class="admin-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">控制面板</a>
        <a href="${pageContext.request.contextPath}/user/profile" class="nav-link">个人资料</a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link">退出登录</a>
    </div>

    <c:if test="${not empty users}">
        <table class="user-table">
            <colgroup>
                <col style="width: 60px">
                <col style="width: 120px">
                <col style="width: 200px">
                <col style="width: 120px">
                <col style="width: 180px">
                <col style="width: 100px">
                <col>
            </colgroup>
            <thead>
            <tr>
                <th>ID</th>
                <th>用户名</th>
                <th>邮箱</th>
                <th>余额</th>
                <th>注册时间</th>
                <th>角色</th>
                <th>操作</th>
            </tr>
            </thead>

            <tbody>
            <c:forEach var="user" items="${users}">
                <tr>
                    <td>${user.id}</td>
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td><strong style="color:#1976d2;">¥ ${user.balance}</strong></td>
                    <td>${user.createdAt}</td>
                    <td>
                        <c:if test="${user.isAdmin}">
                            <span class="admin-badge">管理员</span>
                        </c:if>
                        <c:if test="${not user.isAdmin}">
                            普通用户
                        </c:if>
                    </td>
                    <td>
                        <div class="actions-container">
                            <div class="form-group">
                                <input type="number" id="amount_${user.id}" class="balance-input"
                                       placeholder="金额" step="0.01" min="0.01">
                                <select id="operation_${user.id}" class="operation-select">
                                    <option value="add">增加</option>
                                    <option value="subtract">减少</option>
                                </select>
                                <button class="btn btn-primary" onclick="adjustBalance(${user.id})">调整余额</button>
                            </div>

                            <c:if test="${user.id != admin.id}">
                                <button class="btn btn-danger"
                                        onclick="confirmDelete(${user.id}, '${user.username}')">
                                    删除用户
                                </button>
                            </c:if>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${empty users}">
        <div style="text-align:center;padding:40px;background:white;border-radius:8px;">
            <p>暂无用户数据</p>
        </div>
    </c:if>

</div>

</body>
</html>
