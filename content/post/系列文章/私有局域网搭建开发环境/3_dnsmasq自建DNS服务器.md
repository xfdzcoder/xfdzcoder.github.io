---
url: /7245597786396205056
title: '私有局域网搭建开发环境其三——dnsmasq自建DNS服务器'
date: 2024-09-28T08:59:17+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', 'Debian', '私有局域网搭建开发环境']
---

<hr>

## 参考文献

[dnsmasq 详解及配置 - 老王的自留地 | ivo Blog (ivo-wang.github.io)](https://ivo-wang.github.io/2018/06/02/dnsmasq-详解及配置/)

[Index of / (dnsmasq.org)](https://dnsmasq.org/)

我的配置：

```conf
log-queries

cache-size=2000
clear-on-reload
resolv-file=/etc/resolv.dnsupstream.conf
```

自定义域名在 `/etc/hosts` 文件中定义

`/etc/resolv.dnsupstream.conf` 文件定义上游DNS服务器，然后在 `/etc/resolv.conf` 中新增 `nameserver 本机接口地址` 指向本机的 DNS 服务器



## 问题及解决

### 1. nslookup可以查询到，ping不行

还原案发现场：

DNS服务器建在A电脑，我用B电脑。A和B不在一个物理局域网内，通过 Zerotier 搭建的虚拟局域网相连。所以A、B电脑中各有一张连接WiFi的网卡和一个Zerotier的网卡。

在B端配置DNS服务器时，需要在两个网卡中都配置。

### 2. ping 可以，但是浏览器无法访问

clash的原因，没配置过滤，导致访问自定义域名的时候直接被转发了。

