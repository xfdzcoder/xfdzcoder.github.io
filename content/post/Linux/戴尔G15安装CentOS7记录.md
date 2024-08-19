---
url: /7230148377613213696
title: '戴尔G15安装Debian12记录'
date: 2024-08-16T17:48:43+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', 'Debian']
---

## 1. 安装 Debian 12

打开ISO文件后，单击UltraISO菜单中的“启动”，在弹出的下拉菜单中选择“写入硬盘映像”，然后格式化后写入即可

开机动画时按 F2 进入 BIOS，修改引导程序优先级为 U盘然后重启进入安装

## 2. 安装后设置

### 2.1 vi 无法使用 Backspace

[Linux之vi编辑模式下Backspace无法退格删除和上下左右出现字母问题解决_:set nocp-CSDN博客](https://blog.csdn.net/u011304490/article/details/81367490)

### 2.2 更换 apt 源

[debian | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/debian/)

然后更新软件包

```bash
apt update
apt upgrade
```

### 2.3 修改笔记本的关盖动作

[Debian设置合上笔记本盖子不休眠_debian 12 关闭笔记本屏幕-CSDN博客](https://blog.csdn.net/acxlm/article/details/78248819)

### 2.4 连接有线网

修改 `/etc/network/interfaces` 文件

添加如下配置：

```
# auto 表示自动配置
auto 网卡名称
iface 网卡名称 inet static
        address 192.168.xx.xx
        netmask 255.255.255.0
        gateway 192.168.xx.1
```

修改 `/etc/resolv.conf` 文件，添加 DNS 服务器，这俩都是 阿里云公共DNS

```
nameserver 223.5.5.5
nameserver 223.6.6.6
```

### 2.5 安装 vim

```
apt install vim -y
```

### 2.6 配置密钥登录

```bash
ssh-keygen.exe -t rsa -C "xfdz-xiaomi"
scp .\id_rsa_xfdz_debian.pub root@192.168.1.9:/root/
cd ~/.ssh
touch authorized_keys
cat ../id_rsa_xfdz_debian.pub > ./authorized_keys
```

然后在客户端这边把密钥文件保存到一个安全的地方即可

### 2.7 vim 无法使用系统剪贴板

```
apt install vim-gtk3
```

### 2.8 Vim 的配置

```
set encoding=utf8
" 显示行号
set nu
" 修改鼠标模式为命令行模式
set mouse=c
```

### 2.9 frp

[frp (gofrp.org)](https://gofrp.org/zh-cn/)

[Release v0.59.0 · fatedier/frp (github.com)](https://github.com/fatedier/frp/releases/tag/v0.59.0)

下载合适的版本，然后将其上传到服务器

```
scp -i "密钥位置" D:\downloads\idm\frp_0.59.0_linux_amd64_4.tar.gz root@192.168.1.9:/root
```

然后解压 frp

```bash
root@xfdz-debian:~# mv frp_0.59.0_linux_amd64_4.tar.gz /opt/
root@xfdz-debian:~# cd /opt/
root@xfdz-debian:/opt# ls -al
total 12092
drwxr-xr-x  2 root root     4096 Aug 16 17:19 .
drwxr-xr-x 18 root root     4096 Aug 16 13:34 ..
-rw-r--r--  1 root root 12370199 Aug 16 17:16 frp_0.59.0_linux_amd64_4.tar.gz
root@xfdz-debian:/opt# tar -xvzf frp_0.59.0_linux_amd64_4.tar.gz
frp_0.59.0_linux_amd64/
frp_0.59.0_linux_amd64/frpc
frp_0.59.0_linux_amd64/LICENSE
frp_0.59.0_linux_amd64/frpc.toml
frp_0.59.0_linux_amd64/frps.toml
frp_0.59.0_linux_amd64/frps
root@xfdz-debian:/opt# ls -al
total 12096
drwxr-xr-x  3 root root     4096 Aug 16 17:19 .
drwxr-xr-x 18 root root     4096 Aug 16 13:34 ..
drwxr-xr-x  2 1001  127     4096 Jul  9 11:03 frp_0.59.0_linux_amd64
-rw-r--r--  1 root root 12370199 Aug 16 17:16 frp_0.59.0_linux_amd64_4.tar.gz
root@xfdz-debian:/opt# mv frp_0.59.0_linux_amd64 frp
root@xfdz-debian:/opt# rm -rf frp
frp/                             frp_0.59.0_linux_amd64_4.tar.gz
root@xfdz-debian:/opt# rm -rf frp_0.59.0_linux_amd64_4.tar.gz
root@xfdz-debian:/opt# ls -al
total 12
drwxr-xr-x  3 root root 4096 Aug 16 17:20 .
drwxr-xr-x 18 root root 4096 Aug 16 13:34 ..
drwxr-xr-x  2 1001  127 4096 Jul  9 11:03 frp
```

然后参考官网教程：[使用 systemd | frp (gofrp.org)](https://gofrp.org/zh-cn/docs/setup/systemd/)

### 2.10 安装配置 Git

详见：[微服务环境搭建记录](xfdzcoder.github.io/7229097476379156480)

