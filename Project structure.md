# 项目结构

```
online-bank/
├── pom.xml                    # Maven 项目配置文件，管理依赖和构建
├── online_bank.sql           # 数据库初始化脚本（建库、建表、初始数据）
├── src/main/java/com/example/onlinebank/
│   ├── controller/           # 控制器层，接收请求并返回视图或数据
│   │   ├── AdminController.java   # 管理员相关接口（后台、用户管理）
│   │   └── UserController.java    # 用户接口（注册、登录、资料管理）
│   ├── mapper/              # 数据访问层（DAO）
│   │   ├── EmailCodeMapper.java   # 邮箱验证码表的数据库操作接口
│   │   └── UserMapper.java        # 用户表的数据库操作接口
│   ├── model/               # 实体类（与数据库表对应）
│   │   ├── EmailCode.java         # 邮箱验证码实体
│   │   └── User.java              # 用户实体
│   └── service/             # 业务逻辑层
│       └── UserService.java       # 用户相关业务逻辑处理
├── src/main/resources/
│   ├── email.properties     # 邮件发送配置（SMTP、账号、授权码）
│   └── mybatis/mappers/     # MyBatis SQL 映射文件目录
│       ├── EmailCodeMapper.xml    # 邮箱验证码相关 SQL 映射
│       └── UserMapper.xml         # 用户表相关 SQL 映射
└── src/main/webapp/
    ├── index.jsp            # 重定向到 login.jsp
    ├── uploads/             # 文件上传目录（头像）
    │   ├── default_avatar.png     # 默认用户头像
    │   └── ... (用户上传头像)     # 用户上传的资源头像
    └── WEB-INF/
        ├── views/           # JSP 视图页面
        │   ├── login.jsp          # 登录页面
        │   ├── register.jsp       # 注册页面
        │   ├── profile.jsp        # 用户个人资料页面
        │   ├── forgot.jsp         # 找回密码页面
        │   ├── deleteAccount.jsp  # 注销账号页面
        │   └── admin/
        │       ├── dashboard.jsp  # 管理员仪表盘页面
        │       └── users.jsp      # 管理员用户管理页面
        ├── applicationContext.xml # Spring 核心配置
        ├── spring-mvc.xml         # Spring MVC 配置
        └── web.xml                # Web 应用配置
```