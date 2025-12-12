# 项目结构

```
online-bank/
├── pom.xml                    # Maven配置文件
├── online_bank.sql           # 数据库初始化脚本
├── src/main/java/com/example/onlinebank/
│   ├── controller/           # 控制器层
│   │   ├── AdminController.java
│   │   └── UserController.java
│   ├── mapper/              # 数据访问层
│   │   ├── EmailCodeMapper.java
│   │   └── UserMapper.java
│   ├── model/               # 数据模型
│   │   ├── EmailCode.java
│   │   └── User.java
│   └── service/             # 业务逻辑层
│       └── UserService.java
├── src/main/resources/
│   ├── email.properties     # 邮箱配置
│   └── mybatis/mappers/     # MyBatis映射文件
│       ├── EmailCodeMapper.xml
│       └── UserMapper.xml
└── src/main/webapp/
    ├── index.jsp            # 首页
    ├── uploads/             # 文件上传目录
    │   ├── default_avatar.png
    │   └── ... (用户上传文件)
    └── WEB-INF/
        ├── views/           # JSP视图文件
        │   ├── login.jsp
        │   ├── register.jsp
        │   ├── profile.jsp
        │   ├── forgot.jsp
        │   ├── deleteAccount.jsp
        │   └── admin/
        │       ├── dashboard.jsp
        │       └── users.jsp
        ├── applicationContext.xml  # Spring主配置文件
        ├── spring-mvc.xml          # Spring MVC配置
        └── web.xml                 # Web应用配置
```