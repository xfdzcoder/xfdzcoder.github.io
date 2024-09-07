---
url: /7238165878154502144
title: 'Minio之前端直传'
date: 2024-09-07T20:47:17+08:00
draft: false
summary: ""
categories: [其他]
tags: ['top', 'minio']
---



## 引言

要不要前端直传？根据需求，这次准备搭建一个试试。

[上传文件应该经过后端吗，还是直接上传至阿里oss? - 知乎 (zhihu.com)](https://www.zhihu.com/question/461803154)

已有技术：

https://github.com/kangaroo1122/minio-spring-boot-starter

相关文档：

[Java 快速入门指南](https://min.io/docs/minio/linux/developers/java/minio-java.html#)

[获取PresignedPostFormData（PostPolicy 策略）](https://min.io/docs/minio/linux/developers/java/API.html#getpresignedpostformdata-postpolicy-policy)

[PostPolicy](http://minio.github.io/minio-java/io/minio/MinioClient.html#getPresignedPostFormData-io.minio.PostPolicy-)

[POST 策略](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTConstructPolicy.html)

