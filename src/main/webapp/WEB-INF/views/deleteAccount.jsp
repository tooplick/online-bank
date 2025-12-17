<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>注销账户 - 极简银行</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        :root {
            --primary-black: #121212;
            --danger-red: #ff3b30;
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

        .content-section {
            width: 100%;
            max-width: 480px; /* 稍微宽一点以便阅读警告内容 */
        }

        .brand-title {
            font-size: 2rem;
            font-weight: 700;
            letter-spacing: -1px;
            margin-bottom: 0.5rem;
            color: var(--danger-red);
        }

        /* 警告文本列表化 */
        .warning-box {
            margin: 2rem 0;
            padding-left: 0;
            list-style: none;
            border-left: 2px solid var(--danger-red);
            padding-left: 1.5rem;
        }

        .warning-box li {
            font-size: 0.95rem;
            color: #555;
            margin-bottom: 0.8rem;
            line-height: 1.6;
        }

        /* 信息展示行 */
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 1rem 0;
            border-bottom: 1px solid var(--border-light);
            font-size: 0.9rem;
        }

        .info-label {
            color: var(--muted-gray);
            font-weight: 500;
        }

        /* 输入与验证码 */
        .form-group-custom {
            margin-top: 3rem;
            position: relative;
        }

        .input-underlined {
            width: 100%;
            border: none;
            border-bottom: 1px solid var(--border-light);
            border-radius: 0;
            padding: 12px 0;
            font-size: 1.1rem;
            background: transparent;
            transition: border-color 0.3s;
        }

        .input-underlined:focus {
            outline: none;
            border-bottom-color: var(--primary-black);
        }

        .btn-send-text {
            position: absolute;
            right: 0;
            bottom: 12px;
            background: none;
            border: none;
            color: var(--accent-blue, #0052ff);
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
        }

        /* 按钮组 */
        .action-btns {
            margin-top: 3rem;
            display: flex;
            gap: 1.5rem;
            align-items: center;
        }

        .btn-confirm {
            background: var(--danger-red);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 4px;
            font-weight: 600;
            flex: 2;
        }

        .btn-cancel {
            color: var(--muted-gray);
            text-decoration: none;
            font-size: 0.9rem;
            flex: 1;
            text-align: center;
        }

        /* 状态提示胶囊 */
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
        }
    </style>
</head>
<body>

<div id="status-toast"></div>

<div class="viewport-wrapper">
    <main class="content-section">
        <header>
            <h1 class="brand-title">注销账户</h1>
            <p class="text-muted">这是一个永久性的操作，请审慎决定。</p>
        </header>

        <ul class="warning-box">
            <li><strong>数据抹除：</strong> 所有交易记录与个人资料将被永久删除。</li>
            <li><strong>不可逆性：</strong> 注销后无法通过任何手段找回账户。</li>
            <li><strong>余额清零：</strong> 只有余额为 0 的账户可以申请注销。</li>
        </ul>

        <div class="account-summary mb-5">
            <div class="info-row">
                <span class="info-label">账户名</span>
                <span>${user.username}</span>
            </div>
            <div class="info-row">
                <span class="info-label">当前余额</span>
                <span class="${isBalanceZero ? 'text-success' : 'text-danger fw-bold'}">
                    ¥ ${user.balance} ${isBalanceZero ? '' : '(需清零)'}
                </span>
            </div>
        </div>

        <c:choose>
            <c:when test="${isBalanceZero}">
                <form action="${pageContext.request.contextPath}/user/confirmDelete" method="post" onsubmit="return confirmDelete()">
                    <div class="form-group-custom">
                        <label class="info-label small text-uppercase">身份验证</label>
                        <input type="text" id="code" name="code" class="input-underlined" placeholder="输入发送至邮箱的验证码" maxlength="6" required>
                        <button type="button" class="btn-send-text" id="sendCodeBtn" onclick="sendDeleteCode()">获取验证码</button>
                    </div>

                    <div class="action-btns">
                        <button type="submit" class="btn-confirm">确认永久注销</button>
                        <a href="${pageContext.request.contextPath}/user/profile" class="btn-cancel">取消并返回</a>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <div class="mt-5">
                    <p class="small text-danger mb-4">您的余额不为零，暂无法注销。请先进行提现操作。</p>
                    <a href="${pageContext.request.contextPath}/user/profile" class="btn-confirm d-block text-center text-decoration-none">返回提现</a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<script>
    lucide.createIcons();
    let countdown = 60, timer = null;

    function showStatus(msg, isError = false) {
        const toast = document.getElementById('status-toast');
        toast.innerText = msg;
        toast.style.backgroundColor = isError ? '#ff3b30' : '#121212';
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 4000);
    }

    function sendDeleteCode() {
        const btn = document.getElementById('sendCodeBtn');
        btn.disabled = true;

        timer = setInterval(() => {
            if (--countdown <= 0) {
                clearInterval(timer);
                btn.innerText = '获取验证码';
                btn.disabled = false;
                countdown = 60;
            } else {
                btn.innerText = countdown + 's';
            }
        }, 1000);

        fetch('${pageContext.request.contextPath}/user/sendDeleteCode', { method: 'POST' })
            .then(r => r.text())
            .then(res => {
                if (res.trim() === 'sent') showStatus('验证码已发送至您的邮箱');
                else {
                    showStatus('发送失败: ' + res.trim(), true);
                    clearInterval(timer); btn.innerText = '获取验证码'; btn.disabled = false;
                }
            });
    }

    function confirmDelete() {
        return confirm('这是最后一次确认：您真的要注销吗？');
    }

    <c:if test="${not empty error}">
    showStatus('${error}', true);
    </c:if>
</script>

</body>
</html>