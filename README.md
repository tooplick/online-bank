# 在线银行系统 (Online Banking System)

一个基于Java Spring的在线银行管理系统，提供用户注册、登录、账户管理、电子邮件验证和管理员后台等功能。

## 功能特性

### 用户功能
- 用户注册（带邮箱验证）
- 用户登录/退出
- 个人信息管理
- 密码找回功能
- 账户注销


### 管理员功能
- 管理员登录
- 用户管理
- 系统监控
- 数据统计

## 技术栈

### 后端框架
- Java 8+
- Spring Framework 5.x
- Spring MVC
- MyBatis 3.x

### 前端技术
- JSP (Java Server Pages)
- HTML/CSS/JavaScript
- Bootstrap (可选)

### 数据库
- MySQL 8.0+
- 数据库脚本：online_bank.sql

### 服务器
- Apache Tomcat 9.x

### 依赖管理
- Maven

## 项目结构

详情见：[**Project structure.md**](./Project%20structure.md)

## 快速开始

### 环境要求
1. Java JDK 8或更高版本
2. MySQL 8.0+
3. Apache Tomcat 9.x
4. Maven 3.6+

### 安装步骤

#### 1. 克隆项目
```bash
git clone https://github.com/yourusername/online-bank.git
cd online-bank
```

#### 2. 数据库设置
```sql
-- 创建数据库
CREATE DATABASE online_bank DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE online_bank;

-- 导入SQL文件
SOURCE path/to/online_bank.sql;

-- 或者直接在MySQL客户端中运行SQL文件
```

#### 3. 项目配置

**A. 数据库连接配置**
编辑 src/main/webapp/WEB-INF/applicationContext.xml 文件：
```xml
<property name="driverClassName" value="com.mysql.cj.jdbc.Driver"/>
<property name="url" value="jdbc:mysql://localhost:3306/online_bank?useSSL=false&amp;serverTimezone=UTC&amp;characterEncoding=utf8"/>
<property name="username" value="your_username"/>
<property name="password" value="your_password"/>
```

**B. 邮箱服务配置**
编辑 src/main/resources/email.properties 文件：
```properties
# QQ 邮箱 SMTP 示例配置
mail.smtp.host=smtp.qq.com
mail.smtp.port=587
mail.username=your-email@example.com
# 这里写 QQ 邮箱的 SMTP 授权码（不是 QQ 登录密码）
mail.password=your-email-password
mail.smtp.auth=true
mail.smtp.ssl.enable=true

```

#### 4. 构建项目
```bash
mvn clean package
```

#### 5. 部署到Tomcat
1. 将生成的 target/online-bank.war 文件复制到Tomcat的 webapps/ 目录
2. 启动Tomcat服务器
3. 访问：http://localhost:8080/

## 配置文件说明

### 数据库表结构
- users - 用户表（存储用户基本信息）
- email_codes - 邮箱验证码表（存储邮箱验证码）

### 默认账户
- 普通用户：注册后通过邮箱验证激活
- 管理员账户：
  - 请设置数据库里相应账号is_admin值为1

## 测试账户

### 用户登录测试
1. 访问注册页面创建新账户
2. 检查邮箱获取验证码
3. 使用验证码完成注册
4. 登录系统


## 开发指南

### 添加新功能
1. 在 model 包中创建实体类
2. 在 mapper 包中创建数据访问接口和XML映射
3. 在 service 包中实现业务逻辑
4. 在 controller 包中创建控制器
5. 在 webapp/WEB-INF/views 中创建JSP视图

## 许可证

本项目基于 MIT License 许可证开源。

## 贡献指南

1. Fork 本仓库
2. 创建功能分支 (git checkout -b feature/AmazingFeature)
3. 提交更改 (git commit -m 'Add some AmazingFeature')
4. 推送到分支 (git push origin feature/AmazingFeature)
5. 开启一个 Pull Request

## 联系与支持

如有问题或建议，请通过以下方式联系：
- 提交 Issue
- 通过邮箱联系我:  [Gmail](mailto:id6543156918@gmail.com)



