---
url: /7239880408618278912
title: 'ForkJoinPool 的坑'
date: 2024-09-12T14:20:04+08:00
draft: false
summary: "ForkJoinPool 的坑"
categories: [框架]
tags: ['top', 'dubbo', 'CompletableFuture', 'ForkJoinPool']
---

## 结论

`CompletableFuture` 中默认的 `ForkJoinPool`  使用的 `ForkJoinPool.commonPool()` 线程池创建的线程的上下文类加载器是 `AppClassLoader` ，`AppClassLoader` 无法读取 `SpringBoot` 的 Jar 包 `BOOT-INF/lib` 下的 `MySQL` 驱动，导致无法找到驱动创建连接。

解决：

自定义线程池即可。

## 过程

##### 长文警告

在毕业设计中想学习一下 `dubbo` 的基本使用，然后就上官网看[3 - 基于 Spring Boot Starter 开发微服务应用 | Apache Dubbo](https://cn.dubbo.apache.org/zh-cn/overview/mannual/java-sdk/quick-start/spring-boot/)了，官网还提供了[Nacos | Apache Dubbo](https://cn.dubbo.apache.org/zh-cn/overview/mannual/java-sdk/reference-manual/registry/nacos/)，但是在使用过程中出现了一些问题

问题1：通过 Dubbo 的异步调用时出现错误：

```
Caused by: java.sql.SQLException: Unable to find a driver that accepts jdbc:mysql://xxx.xxx.xxx.xxx:xxxx/noj
        at com.p6spy.engine.spy.P6SpyDriver.findPassthru(P6SpyDriver.java:131)
        at com.p6spy.engine.spy.P6SpyDriver.connect(P6SpyDriver.java:87)
        at com.zaxxer.hikari.util.DriverDataSource.getConnection(DriverDataSource.java:138)
        at com.zaxxer.hikari.pool.PoolBase.newConnection(PoolBase.java:359)
        at com.zaxxer.hikari.pool.PoolBase.newPoolEntry(PoolBase.java:201)
        at com.zaxxer.hikari.pool.HikariPool.createPoolEntry(HikariPool.java:470)
        at com.zaxxer.hikari.pool.HikariPool.checkFailFast(HikariPool.java:561)
        at com.zaxxer.hikari.pool.HikariPool.<init>(HikariPool.java:100)
        at com.zaxxer.hikari.HikariDataSource.getConnection(HikariDataSource.java:112)
        at com.p6spy.engine.spy.P6DataSource.getConnection(P6DataSource.java:300)
        at org.springframework.jdbc.datasource.DelegatingDataSource.getConnection(DelegatingDataSource.java:101)
        at org.springframework.jdbc.datasource.DataSourceUtils.fetchConnection(DataSourceUtils.java:160)
        at org.springframework.jdbc.datasource.DataSourceUtils.doGetConnection(DataSourceUtils.java:118)
        at org.springframework.jdbc.datasource.DataSourceUtils.getConnection(DataSourceUtils.java:81)
        ... 39 common frames omitted
```

提示找不到mysql的驱动，但我一想这怎么可能呢？于是写了一个 Test 接口进行测试，测试接口可以查询数据库，一番搜索也没有找到解决方案，于是只能自己 debug，debug 的首选位置放在 `P6SpyDriver.findPassthru` 中，可以看到代码不多，大致意思就是从已经注册的驱动类里面找到可以和url匹配的，那么问题一定在 `registeredDrivers` 里

![image-20240912114119782](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F11-41-20-12ef271c7c623525aaa081c37d40359e-image-20240912114119782-299ee7.png)

`registeredDrivers` 的方法如下，一个for循环，里面还有一个很熟悉的老朋友 `DriverManager.getDrivers()` ，`DriverManageer` 应该只在学习 `JDBC` 的时候接触过，然后就没用过了，追入看看

![image-20240912114149269](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F11-41-50-7abb9a131dc8921afc59d4ad153e5929-image-20240912114149269-54ea9f.png)

从这里就能看到确实是在加载驱动，而且会调用 `ensureDriversInitialized` 进行加载

![image-20240912114235024](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F11-42-35-e91da59f6a04907aa6b963f8ac730277-image-20240912114235024-c79f68.png)

进来之后可以看到，这里使用了一个双检锁，判断是否已经初始化过，并且这里已经初始化了，这不对，一定是在前面被初始化了，于是倒回去找找在哪

![image-20240912114439556](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-47-04-7df19d4a113cbbe2e4be73c07e3cdc6c-image-20240912114439556-c0eded.png)

然后就会发现，在现在是正在初始化 `HikariPool` ，并且在调用 `checkFailFast` 之前还调用了 `super(config)` ，会不会是在初始化父连接池的时候提前把驱动初始化了，因为驱动的加载显然不应该交由子类完成，于是重启一遍之后继续追入  `super(config)` （之所以重启是因为需要让驱动重新恢复到未初始化的状态，如果已经初始化了那么Class已经被JVM加载，无法进行后续的 `debug`）

![image-20240912114632296](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F11-46-33-117d61831697568a6d3f1994f2778335-image-20240912114632296-5d580c.png)

进入到 `super(config)` 我们可以发现他的父类是 PoolBase，并且在这里面也进行了一个初始化数据源的操作，进入看看

![image-20240912122640365](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-26-57-872f7fde559434afab9539fcec413e58-image-20240912122640365-db2942.png)

这里会创建一个数据源，再进

![image-20240912122802384](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-28-03-61a84006cf1f15d9599a6f86ca88431e-image-20240912122802384-260bd1.png)

在这个 `DriverDataSource` 的构造器中可以发现一个 `DriverManager.getDrivers();` ，这就真相大白了，这边已经提前进行初始化了。

![image-20240912122931349](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-29-32-c8f2aa87f9f10576f4ac151bdf59206f-image-20240912122931349-554be7.png)

这个时候就可以看到已经是 false 了，该方法的注释解释道：

> 通过检查 System 属性来加载初始 JDBC 驱动程序 jdbc.drivers，然后使用 {@code ServiceLoader} 机制

`jdbc.drivers` 我们一般没有设置过，也就是说会使用 SPI 机制来加载 MySQL 驱动

![image-20240912123155764](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-31-56-66da427e00fd49ef9a044d29d7c8341e-image-20240912123155764-5ec154.png)

那么我们看看 `mysql-connector-j` 中是否通过 SPI 进行了注册，通过查看驱动 jar 包可以发现确实是注册了，而且其内容就是 `com.mysql.cj.jdbc.Driver`

![image-20240912123423411](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-34-24-fbd2bf145cd24884674dd1b7ac7f2f28-image-20240912123423411-6a4b88.png)

既然如此，我们直接进入到 SPI 的部分，这里同样是通过 `AccessController.doPrivileged` 进行调用的，进入 load 看看做了什么

![image-20240912123549117](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-35-49-2590379fcad89ed463a84440361be898-image-20240912123549117-5c67e1.png)

可以看到这边是获取了当前线程的上下文类加载器，他是 `jdk.internal.loader.ClassLoaders$AppClassLoader@4aa298b7`，也就是应用程序类加载器

![image-20240912123653185](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-47-53-79d370cdfa9fc6b39a65239f9d251ccb-image-20240912123653185-abec26.png)

坑来！这就是找不到mysql驱动的原因！

SpringBoot 应用打成 jar 包后，默认会把依赖的 jar 包放进 `BOOT-INF/lib` 中，如下图：

![image-20240912124108398](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-41-09-bbd67372399392b6bbbd8e318b7296d2-image-20240912124108398-60ae66.png)

但是应用程序类加载器并不知道，所以无法找到这个mysql驱动的jar包。

那为什么平时我们使用的时候可以正常运行呢？

因为我们执行 controller 和 service 的代码都是由 spring 提供的，这些线程的类加载器是 tomcat 提供的，而 springboot 对tomcat 进行了封装，所以这些lib库可以由spring的类加载器进行加载，如下图，可以看到 tomcat 类加载器的父级就是 spring 的 `LaunchedClassLoader`。

![img](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-44-16-122addd8b2772ba55024deeb98e92dfa-122addd8b2772ba55024deeb98e92dfa-5596cd.png)

找到了问题所在就好溯源了，原因是因为在最开始的时候（代码如下图），dubbo 的服务实现类中使用了 `CompletableFuture` ，并且没有指定线程池，默认会使用 `ForkJoinPool.commonPool()` ，而这个线程池的上下文类加载器就是应用类加载器。

![image-20240912124733226](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F12-47-34-7ec27263a8f1433d1be2752a6c90c3a8-image-20240912124733226-70482e.png)

找到了原因，那么就好解决了，只需要自己定义一个线程池（本来想偷懒用ForkJoinPool没想到搬起石头砸自己的脚了），其中的 `DubboServiceThreadFactory` 只是指定了一下线程名称

![image-20240912140628145](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F09%2F12%2F14-06-29-fcb8c360882a77d8ab8000fd2ab8e851-image-20240912140628145-2df0d3.png)

```java
/**
 * @author xfdzcoder
 */

public class DubboServiceThreadFactory implements ThreadFactory {

    private final String prefix;

    private final ThreadGroup group;

    private final AtomicInteger threadId = new AtomicInteger(0);
    
    private static final AtomicInteger factoryId = new AtomicInteger(0);

    public DubboServiceThreadFactory(String prefix) {
        this.group = new ThreadGroup(Thread.currentThread().getThreadGroup(), "Custom-DubboService-" + factoryId.incrementAndGet());
        this.prefix = "Dubbo-" + prefix + "-";
    }


    @Override
    public Thread newThread(Runnable r) {
        Objects.requireNonNull(r, "runnable is null");
        Thread thread = new Thread(group, r);
        thread.setName(prefix + "[#" + threadId.incrementAndGet() + "]");
        return thread;
    }
}
```

？？什么？为什么自定义一个就可以解决？

因为 `Thread` 的构造器中有下面这么一段代码，在这里会使用父线程（也就是由Spring创建的线程）中的 `contextClassLoader`

```java
		// thread locals
        if (!attached) {
            if ((characteristics & NO_INHERIT_THREAD_LOCALS) == 0) {
                ThreadLocal.ThreadLocalMap parentMap = parent.inheritableThreadLocals;
                if (parentMap != null && parentMap.size() > 0) {
                    this.inheritableThreadLocals = ThreadLocal.createInheritedMap(parentMap);
                }
                if (VM.isBooted()) {
                    this.contextClassLoader = contextClassLoader(parent);
                }
            } else if (VM.isBooted()) {
                // default CCL to the system class loader when not inheriting
                this.contextClassLoader = ClassLoader.getSystemClassLoader();
            }
        }
```



