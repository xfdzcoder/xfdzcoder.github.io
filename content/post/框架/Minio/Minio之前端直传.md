---
url: /7238165878154502144
title: 'Minio之前端直传'
date: 2024-09-07T20:47:17+08:00
lastmod: 2024-09-09T21:49:29+08:00
draft: false
summary: ""
categories: [框架]
tags: ['top', 'minio']
---



## 引言

要不要前端直传？根据需求，这次准备搭建一个试试。

[上传文件应该经过后端吗，还是直接上传至阿里oss? - 知乎 (zhihu.com)](https://www.zhihu.com/question/461803154)

已有技术：

https://github.com/kangaroo1122/minio-spring-boot-starter

[介绍 | MinIO-Plus (baldhead.cn)](https://minio-plus-docs.baldhead.cn/guide/intro.html)

相关文档：

[Java 快速入门指南](https://min.io/docs/minio/linux/developers/java/minio-java.html#)

[获取PresignedPostFormData（PostPolicy 策略）](https://min.io/docs/minio/linux/developers/java/API.html#getpresignedpostformdata-postpolicy-policy)

[PostPolicy](http://minio.github.io/minio-java/io/minio/MinioClient.html#getPresignedPostFormData-io.minio.PostPolicy-)

[POST 策略](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTConstructPolicy.html)

## 流程图解

![image](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F09%2F21-30-36-85281dc8f3aaf27a21b429e3c7c05a8a-85281dc8f3aaf27a21b429e3c7c05a8a-242384.png)

## 部分代码实现

### Controller

```java
	@Autowired
    private MinioClient minioClient;

    @Autowired
    private MinioProperties minioProperties;

    @GetMapping("avatar/upload/{hash}")
    public Response<Map<String, String>> getCredentials(@PathVariable("hash") String hash) {
        String bucket = minioProperties.getBucket();
        PostPolicy policy = new PostPolicy(bucket, ZonedDateTime.now().plusHours(2L));
        policy.addContentLengthRangeCondition(100 * 1024, 2 * 1024 * 1024);
        // 不要使用 ACL，否则前端在使用该policy上传时您会收到一个 net::ERR_CONNECTION_RESET 错误
        // policy.addEqualsCondition("acl", "private");
        policy.addStartsWithCondition("Content-Type", MediaType.IMAGE_PNG_VALUE);
        String key = "mini/user/avatar/" + System.currentTimeMillis() + hash + ".png";
        policy.addStartsWithCondition("key", key);
        try {
            Map<String, String> formData = minioClient.getPresignedPostFormData(policy);
            formData.put("key", key);
            formData.put("url", URLUtil.completeUrl(minioProperties.getEndpoint(), bucket));
            formData.put("Content-Type", MediaType.IMAGE_PNG_VALUE);
            return Response.ok(formData);
        } catch (Exception e) {
            log.error(ExceptionUtil.stacktraceToString(e));
            return Response.fail("上传凭证生成失败，请稍后再试");
        }
    }
```

### TypeScript计算Sha256

```typescript
const fileToArrayBuffer = (file: File): Promise<ArrayBuffer> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (event) => resolve(event?.target?.result as ArrayBuffer);
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
}
const bufferToHex = (buffer: ArrayBufferLike) => {
  const byteArray = new Uint8Array(buffer);
  return byteArray.reduce((acc, byte) => acc + byte.toString(16).padStart(2, '0'), '');
}

export const sha256 = async (file: File) => {
  const arrayBuffer: BufferSource = await fileToArrayBuffer(file)
  // 使用SubtleCrypto计算SHA-256 hash
  const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer);
  // 将ArrayBuffer转换为hex字符串
  return bufferToHex(hashBuffer);
}
```

### Axios 上传

```typescript
export const upload = async (file: File) => {
  const hash = await sha256(file)
  // 先获取上传凭证
  return request.get<any, Response<Object>>(`/user/file/avatar/upload/${ hash }`)
    .then(res => {
      const data = new Map<string, string>(Object.entries(res.data))
      const key = data.get('key')
      const url = data.get('url')
      if (! url) {
        console.log('url is null', res)
        return
      }

      const formData = new FormData()
      data.forEach((value, key, map) => {
        formData.append(key, value)
      })
      // 这一步必须放在最后
      formData.append('file', file, key)
      // 这一步是必须的，因为发送给Minio的Post请求不能携带多余的参数
      // 或者可以在后端传回上传凭证时封装为一个对象将两者分开
      formData.delete('url')

      return request.post(url, formData)
    })
}
```

## 注：

### 注1：端口是 9000 不是 9001

### 注2：存储桶的访问策略可以是 private

许多教程都让设置为public，但是直接简单粗暴的设置为public会导致任何人都拥有读写权限，这是极不安全的。哪怕是头像如此常见的资源也只应是所有人可读，而不是可写。

我们可以通过 [getPresignedObjectUrl(GetPresignedObjectUrlArgs args)](https://min.io/docs/minio/linux/developers/java/API.html#getpresignedobjecturl-getpresignedobjecturlargs-args) 来为一些敏感资源做限制。

### 注3：不要使用 ACL

AWS 给的示例在演示 `PostPolicy` 的精确匹配时使用了一个 `{"acl": "public-read" }` 的示例，所以我加上了，然后上传出现 `net::ERR_CONNECTION_RESET 错误`，因为 Minio 不支持 ACL，并且未来也不会支持，详见：[支持对象 ACL #8195](https://github.com/minio/minio/issues/8195)

### 注4：上传成功后没有响应，失败会有XML格式的响应信息

XML示例如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Error>
    <Code>EntityTooLarge</Code>
    <Message>Your proposed upload exceeds the maximum allowed object size.</Message>
    <BucketName>noj</BucketName>
    <Resource>/noj</Resource>
    <Region>server</Region>
    <RequestId>17F396FC74436E5D</RequestId>
    <HostId>dd9025bab4ad464b049177c95eb6ebf374d3b3fd1af9251148b658df7ac2e3e8</HostId>
</Error>
```

