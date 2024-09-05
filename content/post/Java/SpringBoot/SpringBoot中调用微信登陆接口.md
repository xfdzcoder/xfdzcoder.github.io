---
url: /7237283644606291968
title: 'SpringBoot调用微信登录接口踩坑记录'
date: 2024-09-05T10:21:43+08:00
draft: false
summary: "调用微信登录接口"
categories: [Java]
tags: ['top', springboot', '微信小程序', '踩坑记录']
---

<hr>

## 引言

之前写过一次微信小程序登录，下面的坑大概率曾经都踩过，但是居然又踩了一遍，故作如下记录，以防再犯。

相关文档：

[开放能力 / 用户信息 / 小程序登录 (qq.com)](https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/login.html)

[小程序登录 / 小程序登录 (qq.com)](https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/user-login/code2Session.html)

## 环境

SpringBoot 3.2.4

## 坑1：微信小程序无法发送请求（net::ERR_UNSAFE_PORT）

错误码：`net::ERR_UNSAFE_PORT`。报错信息`{"errMsg": "request:fail"}`（一开始根本没想到会是端口的问题，还以为是报错信息错的，因为没有任何提示）

尝试过但无效的解决方案：

- 检查网络
- 检查后端服务
- 配置跨域
- 新建一个最小的原生微信小程序demo发送请求

后来看着 `UNSAFE_PORT` 突然想到，要不换一个试试，结果就成功了~

后端网关服务原端口：6000，更换成 7000 就好了，为啥呢？？？不理解

## 坑2：微信小程序接口响应ContentType是text/plain

官方文档明明写的返回 json，但哪怕加了 `accept` 请求头也会返回 `text/plain`，真够抽象。

那就只能自己手动给 `MappingJackson2HttpMessageConverter` 添加 `text/plain` 的支持了，代码如下：

```java
    // 这里直接从 bean 容器中获取，这样可以使用到SpringBoot为我们准备的 ObjectMapper。
	@Autowired
    private MappingJackson2HttpMessageConverter mappingJackson2HttpMessageConverter;

    @PostConstruct
    public void init() {
        // 修改支持的 MediaType
        mappingJackson2HttpMessageConverter.setSupportedMediaTypes(List.of(MediaType.APPLICATION_JSON, MediaType.TEXT_PLAIN));
        restClient = RestClient.builder()
                               .baseUrl(weChatApiProperties.getCode2session())
                               .messageConverters(httpMessageConverters -> {
                                   // 添加修改后的消息转换器
                                   httpMessageConverters.add(mappingJackson2HttpMessageConverter);
                               })
            // ...
```

