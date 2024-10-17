---
url: /7245436255238922240
title: '私有局域网搭建开发环境其二——Zerotier搭建虚拟局域网'
date: 2024-09-27T22:16:32+08:00
lastmod: 2024-09-27T22:16:32+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', 'Debian', '私有局域网搭建开发环境']
---

<hr>

## 安装

[**ZeroTier Documentation**](https://docs.zerotier.com/)

按照官方文档教程安装即可

## 配置Moon

需要所有设备均可访问的一个设备，比如具有公网IP的服务器，或者你所有设备都在一个真实局域网（那也没必要用Zerotier了

[Private Root Servers](https://docs.zerotier.com/roots)

安装官方文档进行配置即可。

## 目标主机不可达

[ZeroTier内网主机互ping时出现destination host unreachable的解决方案 X-osadminの自留地](https://x-osadmin.com/448.xpost)

> ZeroTier是一个十分好用的组内网软件。但是，部分主机虽然成功连接了ZeroTier并且获得了IP，但是内网中其他主机在ping此IP时，可能会提示Destination host unreachable，可能还伴有端口无法访问等问题，其中Linux主机占多数。这是由于Linux内部回环机制造成的问题。因此，我们可以通过在/etc/sysctl.conf中添加如下配置来解决问题：
>
> ```
> net.ipv4.conf.default.rp_filter = 0
> net.ipv4.conf.all.rp_filter = 0
> net.ipv4.conf.eth0.rp_filter = 0
> net.ipv4.conf.eth1.rp_filter = 0
> ```
>
> 添加完成后，执行：sysctl -p，一切完成。可以通过其他主机ping本机进行测试。
>
> Enjoy~