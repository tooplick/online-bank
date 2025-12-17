<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>用户管理控制台</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        body { background-color: #f4f6f9; font-family: sans-serif; }
        .main-card {
            border: none;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
            border-radius: 12px;
            background: white;
            margin-top: 20px;
            min-height: 90vh;
        }
        .table thead th {
            border-bottom: 2px solid #f0f0f0;
            color: #6c757d;
            font-weight: 600;
            font-size: 0.85rem;
        }
        .table tbody td {
            vertical-align: middle;
            color: #333;
            padding: 1rem 0.5rem;
        }
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #e9ecef;
        }
        .action-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            line-height: 32px;
            text-align: center;
            border-radius: 6px;
            margin: 0 2px;
            border: none;
            transition: all 0.2s;
        }
        .action-btn:hover { transform: translateY(-2px); }

        /* --- 仅优化样式的极简分页 --- */
        .pagination-minimal .page-link {
            border: none;
            background-color: #f8f9fa;
            color: #333;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px !important;
            margin: 0 10px;
            transition: all 0.2s;
        }
        .pagination-minimal .page-link:hover:not(.disabled) {
            background-color: #e9ecef;
            color: #0d6efd;
        }
        .pagination-minimal .disabled .page-link {
            background-color: transparent;
            color: #dee2e6;
            cursor: not-allowed;
        }
        .page-text-info {
            font-weight: 600;
            color: #495057;
            font-size: 0.95rem;
            letter-spacing: 1px;
        }
    </style>
</head>

<body>

<div class="container-fluid px-4">
    <div class="main-card p-4">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-0 fw-bold">👥 用户管理</h4>
                <small class="text-muted">共 ${totalUsers} 位用户</small>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary btn-sm me-2">
                    <i class="fas fa-arrow-left"></i> 返回
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm">
                    <i class="fas fa-sign-out-alt"></i>
                </a>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th class="ps-3">ID</th>
                    <th>用户</th>
                    <th>邮箱</th>
                    <th>余额</th>
                    <th>状态</th>
                    <th class="text-end pe-3">操作</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${users}" var="u">
                    <tr>
                        <td class="ps-3 text-muted">#${u.id}</td>
                        <td>
                            <img class="user-avatar me-2"
                                 src="${pageContext.request.contextPath}${empty u.avatar ? '/uploads/default_avatar.png' : u.avatar}"
                                 onerror="this.src='${pageContext.request.contextPath}/uploads/default_avatar.png'">
                            <span class="fw-medium">${u.username}</span>
                            <c:if test="${u.isAdmin}">
                                <span class="badge bg-warning text-dark ms-1" style="font-size:0.6rem">ADMIN</span>
                            </c:if>
                        </td>
                        <td class="text-secondary">${u.email}</td>
                        <td class="fw-bold">
                            ¥ <fmt:formatNumber value="${u.balance}" pattern="0.00"/>
                        </td>
                        <td><span class="badge bg-success bg-opacity-10 text-success">正常</span></td>
                        <td class="text-end pe-3">
                            <button class="action-btn bg-success bg-opacity-10 text-success" onclick="openBalanceModal(${u.id}, '${u.username}', 'add')">
                                <i class="fas fa-plus"></i>
                            </button>
                            <button class="action-btn bg-warning bg-opacity-10 text-warning" onclick="openBalanceModal(${u.id}, '${u.username}', 'subtract')">
                                <i class="fas fa-minus"></i>
                            </button>
                            <c:if test="${!u.isAdmin}">
                                <button class="action-btn bg-danger bg-opacity-10 text-danger" onclick="deleteUser(${u.id}, '${u.username}')">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="d-flex justify-content-center align-items-center mt-4">
            <nav>
                <ul class="pagination pagination-minimal align-items-center mb-0">
                    <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                        <a class="page-link" href="<c:if test='${currentPage > 1}'>${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}</c:if>">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                    </li>

                    <li class="page-item disabled">
                        <span class="page-text-info px-3">
                            ${currentPage} <span class="text-muted mx-1">/</span> ${totalPages}
                        </span>
                    </li>

                    <li class="page-item <c:if test='${currentPage == totalPages || totalPages == 0}'>disabled</c:if>">
                        <a class="page-link" href="<c:if test='${currentPage < totalPages}'>${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}</c:if>">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<div class="modal fade" id="balanceModal" tabindex="-1">...</div>
<div class="toast-container position-fixed top-0 start-50 translate-middle-x p-3">...</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* 原有 JS 逻辑 */
    function showToast(msg, type = 'success') { /* ... */ }
    function openBalanceModal(id, name, type) { /* ... */ }
    function submitBalance() { /* ... */ }
    function deleteUser(id, name) { /* ... */ }
</script>

</body>
</html>