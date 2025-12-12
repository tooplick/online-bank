<%@ page session="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>注销账号 - 网上银行</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <style>
        /* 简单背景和居中 */
        body {
            background-color: #e9ecef;
            display: flex;
            justify-content: center;
            align-items: flex-start; /* 居上对齐 */
            min-height: 100vh;
            padding: 2rem 1rem;
        }
        .container {
            max-width: 600px;
            /* 确保卡片在消息弹窗下层 */
            position: relative;
            z-index: 1;
        }
        /* 顶部消息弹窗样式 */
        #top-alert-container {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1050; /* 确保在最上层 */
            padding: 10px;
            display: none; /* 默认隐藏 */
        }
        #top-alert-container .alert {
            margin-bottom: 0;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
    </style>
    <script>
        // 计时器变量
        var countdown = 60;
        var timer = null;

        // 显示顶部弹窗的函数
        function showTopAlert(message, type = 'success', duration = 4000) {
            var container = document.getElementById('top-alert-container');
            var alertDiv = document.getElementById('top-alert');

            // 设置消息内容和类型
            alertDiv.className = 'alert alert-' + type + ' text-center';
            alertDiv.innerHTML = message;

            // 显示容器
            container.style.display = 'block';

            // 自动隐藏
            setTimeout(function() {
                container.style.display = 'none';
            }, duration);
        }

        function stopTimerAndRestoreButton(btn) {
            if(timer) clearInterval(timer);
            btn.innerHTML = '发送验证码';
            btn.disabled = false;
            countdown = 60;
        }


        function sendDeleteCode() {
            const btn = document.getElementById('sendCodeBtn');
            const userEmail = "${user.email}"; // 从JSP EL获取邮箱

            // 禁用按钮并启动计时器
            btn.disabled = true;
            btn.innerHTML = countdown + 's 后重试';

            // 如果计时器已存在，先清除
            if (timer) clearInterval(timer);

            timer = setInterval(function() {
                countdown--;
                if (countdown === 0) {
                    clearInterval(timer);
                    btn.innerHTML = '发送验证码';
                    btn.disabled = false;
                    countdown = 60; // 重置计时
                } else {
                    btn.innerHTML = countdown + 's 后重试';
                }
            }, 1000);

            // 发送 AJAX 请求
            fetch('${pageContext.request.contextPath}/user/sendDeleteCode', {
                method: 'POST'
            })
                .then(response => response.text())
                .then(result => {
                    const trimmedResult = result.trim();
                    if (trimmedResult === 'sent') {
                        // 成功提示
                        showTopAlert(`✅ 验证码已发送到您的邮箱 ${userEmail}，请查收！`, 'success', 6000);
                    } else if (trimmedResult === 'not_logged_in') {
                        // 登录失败/会话过期提示
                        showTopAlert('会话已过期，请先登录', 'warning');
                        stopTimerAndRestoreButton(btn); // 停止计时器
                        setTimeout(() => {
                            window.location.href = '${pageContext.request.contextPath}/login';
                        }, 2000);
                    } else if (trimmedResult === 'no_user') {
                        // 无用户提示
                        showTopAlert('❌ 用户不存在，请联系管理员。', 'danger');
                        stopTimerAndRestoreButton(btn);
                    } else {
                        // 其他失败提示
                        showTopAlert('❌ 发送失败，请稍后重试', 'danger');
                        stopTimerAndRestoreButton(btn);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showTopAlert('❌ 请求错误，发送失败。', 'danger');
                    stopTimerAndRestoreButton(btn);
                });
        }

        function confirmDelete() {
            if (!confirm('【最终确认】您确定要永久注销账号吗？此操作不可恢复！')) {
                return false;
            }

            const code = document.getElementById('code').value;
            if (!code || code.length !== 6) {
                showTopAlert('⚠️ 请输入6位验证码', 'warning');
                return false;
            }

            return true;
        }
    </script>
</head>
<body>

<div id="top-alert-container">
    <div id="top-alert" role="alert">
    </div>
</div>

<div class="container card shadow p-4">
    <h2 class="card-title text-danger mb-4 border-bottom pb-2">🗑️ 注销账号</h2>

    <div class="alert alert-danger border-start border-5 border-danger p-3" role="alert">
        <h5 class="alert-heading"><strong>⚠️ 警告：此操作不可逆转！</strong></h5>
        <p>一旦您注销账号，以下数据将被永久删除：</p>
        <ul class="mb-0">
            <li>您的个人账户信息及历史记录。</li>
            <li>您的账户余额（必须确保余额为零）。</li>
            <li>您的个人头像和相关文件。</li>
        </ul>
        <hr class="my-2">
        <p class="mb-0">注销后，您将无法再使用此账号登录网上银行系统。</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger" role="alert"><strong>错误:</strong> ${error}</div>
    </c:if>

    <div class="card mb-4 bg-light">
        <div class="card-body">
            <h5 class="card-title text-primary">当前账户信息</h5>
            <p class="mb-1"><strong>用户名:</strong> ${user.username}</p>
            <p class="mb-1"><strong>邮箱:</strong> ${user.email}</p>
            <p class="mb-0"><strong>账户余额:</strong>
                <c:choose>
                    <c:when test="${isBalanceZero}">
                        <span class="text-success fw-bold">${user.balance} 元（可以注销）</span>
                    </c:when>
                    <c:otherwise>
                        <span class="text-danger fw-bold">${user.balance} 元（请先提现使余额为零）</span>
                    </c:otherwise>
                </c:choose>
            </p>
        </div>
    </div>

    <c:if test="${isBalanceZero}">
        <div class="card p-3 bg-white border-info shadow-sm">
            <h4 class="text-info mb-3">🔒 验证身份</h4>
            <p>为了确保是您本人操作，我们将向您的邮箱 <strong>${user.email}</strong> 发送验证码。</p>

            <div class="d-grid mb-3">
                <button id="sendCodeBtn" class="btn btn-primary" type="button" onclick="sendDeleteCode()">发送验证码</button>
            </div>

            <form action="${pageContext.request.contextPath}/user/confirmDelete" method="post" onsubmit="return confirmDelete()">
                <div class="mb-3">
                    <label for="code" class="form-label fw-bold">请输入6位验证码：</label>
                    <input type="text" id="code" name="code" class="form-control" placeholder="输入验证码" maxlength="6" required>
                </div>

                <div class="d-flex justify-content-between gap-3 mt-4">
                    <button type="submit" class="btn btn-danger btn-lg flex-fill">确认注销账号</button>
                    <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-secondary btn-lg">取消并返回</a>
                </div>
            </form>
        </div>
    </c:if>

    <c:if test="${!isBalanceZero}">
        <div class="alert alert-info border-start border-5 border-info" role="alert">
            <h5 class="alert-heading">请注意！</h5>
            <p>您的账户余额 **${user.balance} 元** 不为零，无法注销账号。</p>
            <p class="mb-0">请先<a href="${pageContext.request.contextPath}/user/profile" class="alert-link">返回个人资料页面</a>进行提现操作，使余额为零后再尝试注销。</p>
        </div>

        <div class="d-grid mt-4">
            <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-primary btn-lg">返回个人资料</a>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
</body>
</html>