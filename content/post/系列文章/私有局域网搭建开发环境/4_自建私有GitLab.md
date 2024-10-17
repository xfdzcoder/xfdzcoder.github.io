---
url: /7245597786396205056
title: '私有局域网搭建开发环境其四——自建私有GitLab'
date: 2024-09-28T09:11:59+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', 'Debian', '私有局域网搭建开发环境']
---

<hr>

## 安装环境

Debian12

## 安装

[Download and install GitLab](https://about.gitlab.com/install/#debian)

1. 如果找不到gitlab-ee包的，运行apt update 看看是不是镜像问题
   - 如果是，那么就更换为[gitlab-ce | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirror.tuna.tsinghua.edu.cn/help/gitlab-ce/)，然后安装命令换 gitlab-ce

2. 减少内存占用：[降低gitlab的资源占用（直接干）_puma: cluster worker 减少-CSDN博客](https://blog.csdn.net/weixin_45272815/article/details/130033903)
   - 16G内存条件下：63.6% -> 36.7%

