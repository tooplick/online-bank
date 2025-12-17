<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>系统控制台 - 极简管理后台</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&amp;display=swap" rel="stylesheet" />

    <style>
        :root {
            --bg-neutral: #f8fafc;        /* 极浅灰蓝 */
            --glass-white: rgba(255, 255, 255, 0.7);
            --border-color: #e2e8f0;
            --text-dark: #334155;        /* 哑光深灰 */
            --text-secondary: #64748b;    /* 冷灰色 */
            --accent-muted: #94a3b8;      /* 莫兰迪蓝灰 */
        }

        body {
            background-color: var(--bg-neutral);
            font-family: 'Noto Sans SC', sans-serif;
            color: var(--text-dark);
            margin: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* 顶部导航 - 全屏流式 */
        .navbar-minimal {
            background: var(--glass-white);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--border-color);
            padding: 0.8rem 2.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .brand-text {
            font-weight: 700;
            letter-spacing: 1px;
            color: var(--text-dark);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* 全屏主内容区 */
        .viewport-wrapper {
            flex: 1;
            padding: 3rem 2.5rem;
            width: 100%;
        }

        /* 核心数据卡片网格 */
        .stat-group {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 2rem;
            margin-bottom: 4rem;
        }

        .flat-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 2rem;
            transition: all 0.2s ease;
        }

        .flat-card:hover {
            border-color: var(--accent-muted);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.02);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .stat-title {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        .stat-num {
            font-size: 2.25rem;
            font-weight: 800;
            color: var(--text-dark);
        }

        /* 快捷操作入口 */
        .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            max-width: 800px; /* 限制宽度使布局更精致 */
        }

        .action-item {
            display: flex;
            align-items: center;
            padding: 1.5rem;
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 14px;
            text-decoration: none;
            color: var(--text-dark);
            transition: all 0.2s;
        }

        .action-item:hover {
            background: var(--text-dark);
            color: #fff;
            transform: translateY(-3px);
        }

        .action-icon-wrapper {
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f1f5f9;
            border-radius: 10px;
            margin-right: 1.25rem;
            color: var(--text-secondary);
            transition: 0.2s;
        }

        .action-item:hover .action-icon-wrapper {
            background: rgba(255,255,255,0.1);
            color: #fff;
        }

        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
            background-color: #a3e635; /* 运行正常的绿色 */
            box-shadow: 0 0 8px rgba(163, 230, 53, 0.5);
        }

        .admin-badge {
            font-size: 0.7rem;
            background: #f1f5f9;
            padding: 3px 10px;
            border-radius: 6px;
            color: var(--text-secondary);
            font-weight: 600;
        }
    </style>
</head>
<body>

<nav class="navbar-minimal">
    <a href="#" class="brand-text">
        <i data-lucide="layout-dashboard" size="22"></i>
        ADMIN PANEL
    </a>

    <div class="d-flex align-items-center gap-4">
        <div class="d-flex align-items-center gap-3">
            <span class="admin-badge">ROOT</span>
            <span class="fw-semibold small">${admin.username}</span>
        </div>
        <div class="vr" style="height: 20px; opacity: 0.2;"></div>
        <a href="${pageContext.request.contextPath}/logout" class="text-secondary" title="安全退出">
            <i data-lucide="log-out" size="18"></i>
        </a>
    </div>
</nav>

<div class="viewport-wrapper">
    <div class="mb-5">
        <h1 class="h3 fw-bold mb-1">系统资产与用户概览</h1>
        <p class="text-secondary small">SYSTEM OVERVIEW &amp; REAL-TIME MONITORING</p>
    </div>


    <div class="stat-group">
        <div class="flat-card">
            <div class="stat-header">
                <span class="stat-title">注册用户</span>
                <i data-lucide="users-2" size="20" class="text-muted"></i>
            </div>
            <div class="stat-num">${totalUsers}</div>
            <div class="small text-secondary mt-2">活跃账户总数</div>
        </div>

        <div class="flat-card">
            <div class="stat-header">
                <span class="stat-title">资金池总量</span>
                <i data-lucide="wallet" size="20" class="text-muted"></i>
            </div>
            <div class="stat-num">
                <span class="fs-5 fw-normal">¥</span>
                <fmt:formatNumber value="${totalBalance}" pattern="#,##0.00"/>
            </div>
            <div class="small text-secondary mt-2">跨账户流动性总计</div>
        </div>

        <div class="flat-card">
            <div class="stat-header">
                <span class="stat-title">系统引擎状态</span>
                <i data-lucide="shield-check" size="20" class="text-muted"></i>
            </div>
            <div class="stat-num fs-4">
                <span class="status-dot"></span>
                正常运行中
            </div>
        </div>
    </div>

    <div class="mb-4">
        <h2 class="stat-title mb-4">核心管理入口</h2>
        <div class="action-grid">
            <a href="${pageContext.request.contextPath}/admin/users" class="action-item">
                <div class="action-icon-wrapper">
                    <i data-lucide="users" size="20"></i>
                </div>
                <div>
                    <div class="fw-bold small">用户数据库管理</div>
                    <div class="text-secondary" style="font-size: 0.75rem;">编辑、冻结或调整用户资金</div>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/user/profile" class="action-item">
                <div class="action-icon-wrapper">
                    <i data-lucide="arrow-left-right" size="20"></i>
                </div>
                <div>
                    <div class="fw-bold small">返回个人端</div>
                    <div class="text-secondary" style="font-size: 0.75rem;">管理员个人账户中心</div>
                </div>
            </a>
        </div>
    </div>

    <footer class="mt-5 pt-5 border-top text-secondary" style="font-size: 0.7rem; letter-spacing: 1px;">
        <div class="d-flex justify-content-between align-items-center">
            <span>© 2024 ONLINEBANK INTERNAL AUDIT SYSTEM</span>
            <span class="admin-badge">V2.4.5 STABLE</span>
        </div>
    </footer>
</div>

<script>
    // 初始化 Lucide 图标
    lucide.createIcons();
</script>
</body>
</html>