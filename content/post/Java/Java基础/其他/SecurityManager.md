---
url: /7226540759879557120
title: 'SecurityManager的应用'
date: 2024-08-06T18:53:26+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Java基础']
---

<hr>

SecurityManager的作用，他的类文档已经解释的很完善了。下面主要记录一下策略文件。

[Java SecurityManager初识 | Spoock](https://blog.spoock.com/2019/12/21/Getting-Started-with-Java-SecurityManager-from-Zero/)

下面记录一下测试代码

VM 参数：

```shell
-Djava.security.manager 
-Djava.security.policy==D:\projects\java\versions\java8\src\main\resources\versions\java8\sandbox\security\java.policy versions.java8.sandbox.security.SecurityManagerDemo
```

```java
package versions.java8.sandbox.security;

import java.io.File;
import java.io.FilePermission;
import java.io.IOException;
import java.net.Socket;

/**
 * @author: xfdzcoder
 */
public class SecurityManagerDemo {

    public static void main(String[] args) throws IOException {
        SecurityManager manager = System.getSecurityManager();
        try {
            manager.checkPermission(new RuntimePermission("setSecurityManager"));
        } catch (SecurityException e) {
            System.out.println("cannot setSecurityManager");
        }
        try {
            manager.checkPermission(new FilePermission("c:\\", "read"));
        } catch (SecurityException e) {
            System.out.println("cannot readFile C:\\");
        }
        try {
            new Socket("localhost", 80);
        } catch (IOException e) {
            System.out.println("cannot connect to localhost:80");
        }
        try {
            new File("C:\\a.txt");
        } catch (SecurityException e) {
            System.out.println("cannot create file C:\\a.txt");
        }
    }
}
```

