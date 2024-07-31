---
url: /7224233674005610511
title: 'IDEA 与 服务器 Linux 开发'
date: 2023-05-25T22:19:29+08:00
draft: false
summary: ""
categories: [Java]
tags: ['springboot']
---

# IDEA 与 服务器 Linux 开发

最终效果：服务器上有一份与本地相同的代码。

目的：

- 可随时更新项目并将其运行起来测试。
- 避免了一个小更新也要在本地打包然后上传并运行的重复操作

## 0. 要求

- 得有脑子

- 得有一台服务器
- 得有一个 IDEA

## 1. Linux 上安装 JDK

此处省略一万字

## 2. Linux 上安装 Maven

此处省略一万字

## 3. 将代码打包上传到 Linux 并解压

此处省略一万字

## 4. 本地 IDEA 的配置（正文开始）

首先添加远程主机

![image-20221226211656965](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-00-806fed0e7b253cc9efba508fec36ddce-202212262116070-baf92c.png)

点击右上角三个点新建：

![image-20221226211730039](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-02-bf0d65934b9db03b42f952b22dc17789-202212262117080-6f68aa.png)

然后新建SSH配置

![image-20221226211846562](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-05-5c48b2e0316bf445b4441ac910c23cef-202212262118627-6aae6b.png)

然后填写被挡住的地方：

![image-20221226212027220](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-07-7f42c529b813947dd998e76ddb3ceda1-202212262120290-0e3b2e.png)

然后填写映射路径

![image-20221226212514891](http://sgwh1yaa2.hd-bkt.clouddn.com/202212262125952.png)

然后工具中勾选自动上传

![image-20221226212602164](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-12-9ebe0237fe7bb81c9ba5b6bd20f292c7-202212262126214-af7b01.png)