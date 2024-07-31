---
url: /7224233674005610509
title: 'synchronized 的升级机制'
date: 2024-07-30T11:12:26+08:00
lastmod: 2024-07-31T20:03:17+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'JUC']
---

<hr>

## 引言

都 4202 年了，不会还有人以为 synchronized 就是重量级锁吧~，参考：[浅析synchronized锁升级的原理与实现 - 小新成长之路 - 博客园 (cnblogs.com)](https://www.cnblogs.com/star95/p/17542850.html)

在看本章之前，您需要先了解**对象头**是什么？

### 对象头

 在 JVM 中，对象在内存中分为三块区域：

- 对象头：由 `Mark Word` 和 `Klass Point` 构成。

  - **Mark Word**（标记字段）：用于存储对象自身的运行时数据，例如存储对象的HashCode，分代年龄、锁标志位等信息，是synchronized实现轻量级锁和偏向锁的关键。 

    - 该部分在32位JVM中的长度是32bit，在64位JVM中长度是64bit。64位JVM的Mark Word组成如下：（图源：[浅析synchronized锁升级的原理与实现 - 小新成长之路 - 博客园 (cnblogs.com)](https://www.cnblogs.com/star95/p/17542850.html)）

      ![img](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F30%2F13-15-32-73d7b9d23d43b3870d73f821d2a3c4de-3230688-20231101142351434-473719587-c1e159.png)

  - **Klass Point**（类型指针）：对象指向它的类元数据的指针，虚拟机通过这个指针来确定这个对象是哪个类的实例。

    - 该指针在32位JVM中的长度是32bit，在64位JVM中长度是64bit。

  - **数组长度**

    - 只有数组对象保存了这部分数据。该数据在32位和64位JVM中长度都是32bit。

- 实例数据：这部分主要是存放类的数据信息，父类的信息。

- 字节对齐：为了内存的IO性能，JVM要求对象起始地址必须是8字节的整数倍。对于不对齐的对象，需要填充数据进行对齐。

如何查看**对象头**信息？

使用 jol-core 类库

```xml
<dependency>
    <groupId>org.openjdk.jol</groupId>
    <artifactId>jol-core</artifactId>
    <version>0.17</version>
</dependency>
```

代码示例

```java
public class Main {
    
    public static void main(String[] args) throws InterruptedException {
        System.out.println(ClassLayout.parseInstance(new Object()).toPrintable());
    }
    
}
```

打印结果如下：

```
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

想必细心的朋友会发现，这里的类型指针（object header: class）部分，加起来只有 4 个字节，但刚刚不是说 64 位的机器上是 32 位么，这里就可以引申出一个点：JVM 的指针压缩技术

### JVM 的指针压缩技术

[聊一聊JAVA指针压缩的实现原理（图文并茂，让你秒懂）_指针压缩原理-CSDN博客](https://blog.csdn.net/liujianyangbj/article/details/108049482)

64位虚拟机中在堆内存小于32GB的情况下，UseCompressedOops是默认开启的，该参数表示开启指针压缩，会将原来64位的指针压缩为32位。

-XX:+UseCompressedClassPointers //开启压缩类指针
-XX:-UseCompressedClassPointers //关闭压缩类指针

### 为什么 JVM 可以用 4个 byte 寻址范围是 32GB 左右的内存空间

32位操作系统原本是4个字节，32位，可以表示 2³² 个地址，如果一个地址表示 1byte，那么就可以表示 2³² byte = 4GB

JVM 中也是用4个字节，32位，也可以表示 2³² 个地址，但是 JVM 中的对象大小都是 8byte 的倍数（因为有对齐填充），所以一个地址可以表示 8 byte，那么 2³² 个地址就可以表示 2³² * 8 byte = 32GB

## synchronized

了解了如上内容，那么下面就可以开始锁优化机制的学习了。

首先我们要了解 synchronized 在最开始是怎么实现的？

在 JDK6（不包括）之前，synchronized 一直都是使用 Monitor 机制 实现的，monitor的线程互斥就是通过mutex互斥锁实现的，mutex 互斥锁的使用会涉及到上下文的切换（即用户态和内核态的转换），性能消耗极其高，所以在当时synchronized锁是公认的重量级锁。

详见[java并发系列-monitor机制实现 - 青衫执卷 - 博客园 (cnblogs.com)](https://www.cnblogs.com/qingshan-tang/p/12698705.html)

JDK5 引入了 JUC 并发包，包括 Lock 之类的锁来解决同步的性能问题，那么 JDK6 引入了什么来解决传统 synchronized 的性能问题呢？

- 偏向锁
  - 共享资源首次被访问时，JVM会对该共享资源对象做一些设置，比如将对象头中是否偏向锁标志位置为1，对象头中的线程ID设置为当前线程ID（注意：这里是操作系统的线程ID），后续当前线程再次访问这个共享资源时，会根据偏向锁标识跟线程ID进行比对是否相同，比对成功则直接获取到锁，进入**临界区域**（就是被锁保护，线程间只能串行访问的代码），这也是synchronized锁的可重入功能。
  - -XX:+UseBiasedLocking（表示启用偏向锁，想要关闭偏向锁，可添加JVM参数：-XX:-UseBiasedLocking）
  - 偏向锁默认会有一个延迟时间，-XX:BiasedLockingStartupDelay=4000（表示JVM启动4秒后打开偏向锁，也可以自定义这个延迟时间，如果设置成0，那么JVM启动就打开偏向锁）。默认是 4 秒。
  - 另外需要注意的是，由于硬件资源的不断升级，获取锁的成本随之下降，**JDK15版本后默认关闭了偏向锁**。
- 轻量级锁
  - 当多个线程同时申请共享资源锁的访问时，这就产生了竞争，JVM会先尝试使用轻量级锁，以CAS方式来获取锁（一般就是自旋加锁，不阻塞线程采用循环等待的方式），成功则获取到锁，状态为轻量级锁，失败（达到一定的自旋次数还未成功）则锁升级到重量级锁。

所以 JDK6 之后，synchronized 锁就有了四种状态：

- 无锁
- 偏向锁
- 轻量级锁
- 重量级锁

这4种级别的锁，在获取时性能消耗：重量级锁 > 轻量级锁 > 偏向锁 > 无锁。

## synchronized 升级

这里再放一个对象头信息的图，大家和打印结果结合起来理解。（图源：[浅析synchronized锁升级的原理与实现 - 小新成长之路 - 博客园 (cnblogs.com)](https://www.cnblogs.com/star95/p/17542850.html)）

![img](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F30%2F13-15-32-73d7b9d23d43b3870d73f821d2a3c4de-3230688-20231101142351434-473719587-c1e159.png)

还有一个 print 方法，负责打印提示信息和对象内存结构。`StrUtil.fillBefore` 方法是 hutool 工具包中的，需要导入以下依赖：

```xml
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.23</version>
</dependency>
```

```java
private static void print(String msg, Object obj) {
    StringBuilder appender = new StringBuilder();
    appender
        .append(msg)
        .append("\t\t\t\t--- ")
        .append(LocalDateTime.now())
        .append("\n")
        .append("mark word:");

    // Long 转 byte
    String[] strings = StrUtil.split(StrUtil.fillBefore(Long.toBinaryString(VM.current().getLong(obj, 0)), '0', 64), 8);
    for (String s : strings) {
        appender.append(" ").append(s);
    }
    appender.append("\n").append(ClassLayout.parseInstance(obj).toPrintable());
    System.out.println(appender);
}
```



### 无锁 to 偏向锁

代码很简单，这里就不做解释了，主要通过打印结果来分析锁的情况

```java
package versions.java8.juc.sync;

import cn.hutool.core.util.StrUtil;
import org.openjdk.jol.info.ClassLayout;
import org.openjdk.jol.vm.VM;

import java.time.LocalDateTime;

/**
 * @author: Ding
 */

public class synchronizedUpgrade {


    public static void main(String[] args) throws InterruptedException {
        nonBiasable2Biasable();
    }
    private static void nonBiasable2Biasable() throws InterruptedException {
        Object obj = new Object();
        print("虚拟机刚启动", obj);
        synchronized (obj) {
            print("进入 synchronized", obj);
        }
        Thread.sleep(5000);
        // 这里是为了替换掉在 偏向锁开启的延迟时间内（JVM 启动的 4s 内） 内创建的 obj，偏向锁开启的延迟时间内创建的对象是不会进入偏向锁状态的
        obj = new Object();
        print("睡眠五秒后", obj);
        synchronized (obj) {
            print("进入 synchronized", obj);
        }
    }
}
```

```
虚拟机刚启动				--- 2024-07-30T13:12:13.502
mark word: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000001
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

进入 synchronized				--- 2024-07-30T13:12:15.062
mark word: 00000000 00000000 00000000 10001001 10110011 00011111 11110101 11010000
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x00000089b31ff5d0 (thin lock: 0x00000089b31ff5d0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

睡眠五秒后				--- 2024-07-30T13:12:20.070
mark word: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x0000000000000005 (biasable; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

进入 synchronized				--- 2024-07-30T13:12:20.072
mark word: 00000000 00000000 00000001 10101101 11011010 01011100 11011000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x000001adda5cd805 (biased: 0x000000006b769736; epoch: 0; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

退出 synchronized				--- 2024-07-30T13:12:20.074
mark word: 00000000 00000000 00000001 10101101 11011010 01011100 11011000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x000001adda5cd805 (biased: 0x000000006b769736; epoch: 0; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

从运行结果可以看到，虚拟机刚启动时的锁是 non-biasable （不可偏向的），也就是无锁且不可偏向，此时如果尝试进入 synchronized，将会直接升级为 thin lock（轻量级锁）。

睡眠五秒后，重新创建了一个对象，并打印其内存结构发现是 biasable（可偏向的），并且是偏向锁的情况，但是此时并没有线程获取这个对象的锁，并且根据内存结构图来看，thread 和 epoch 的 位置的均为0，说明当前偏向锁并没有偏向任何线程，此时的锁出于 匿名偏向状态。

`匿名偏向状态`：锁对象mark word标志位为101，且存储的 `Thread ID` 为空时的状态(即锁对象为偏向锁，且没有线程偏向于这个锁对象)。

然后线程进入 synchronized，锁偏向当前线程，变成 biased，并且前面存储了部分信息。

注：只有锁对象处于**匿名偏向**状态，线程才能拿到到我们通常意义上的偏向锁。而处于无锁状态的锁对象，只能进入到轻量级锁状态。

### 无锁 to 轻量级锁

1. 在 偏向锁开启的延迟时间内 进入锁，会直接升级为 轻量级锁
2. 当锁对象调用过 `Object#hashCode` 或者 `System#identityHashCode(Object)` 后，将无法进入偏向锁状态，如果有线程尝试获取锁那么也会直接升级到轻量级锁

### 偏向锁 to 轻量级锁

```java
private static void biasable2thinLock() throws InterruptedException {
    Thread.sleep(5000);
    Object obj = new Object();
    Thread t1 = new Thread(() -> {
        print("t1 拿锁前", obj);
        synchronized (obj) {
            print("t1 拿到锁", obj);
        }
        print("t1 释放锁", obj);
        while (true) {}
    });
    t1.start();
    Thread.sleep(1000);
    Thread t2 = new Thread(() -> {
        print("t2 拿锁前", obj);
        synchronized (obj) {
            print("t2 拿到锁", obj);
        }
        print("t2 释放锁", obj);
    });
    t2.start();
}
```

```
t1 拿锁前				--- 2024-07-30T15:52:59.889
mark word: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x0000000000000005 (biasable; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t1 拿到锁				--- 2024-07-30T15:53:01.406
mark word: 00000000 00000000 00000001 10000111 11110011 10111011 11111000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x00000187f3bbf805 (biased: 0x0000000061fceefe; epoch: 0; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t1 释放锁				--- 2024-07-30T15:53:01.407
mark word: 00000000 00000000 00000001 10000111 11110011 10111011 11111000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x00000187f3bbf805 (biased: 0x0000000061fceefe; epoch: 0; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t2 拿锁前				--- 2024-07-30T15:53:00.892
mark word: 00000000 00000000 00000001 10000111 11110011 10111011 11111000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x00000187f3bbf805 (biased: 0x0000000061fceefe; epoch: 0; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t2 拿到锁				--- 2024-07-30T15:53:01.419
mark word: 00000000 00000000 00000000 00111010 11101101 10001111 11101101 11000000
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x0000003aed8fedc0 (thin lock: 0x0000003aed8fedc0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t2 释放锁				--- 2024-07-30T15:53:01.420
mark word: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000001
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
  0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
  8   4        (object header: class)    0xf80001e5
 12   4        (object alignment gap)    
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

当 t2 尝试获取锁时，锁偏向 t1 并且已经释放了锁，这就会升级到轻量级锁。

### 轻量级锁 to 重量级锁

```java
private static void thinLock2FatLock() throws InterruptedException {
    Thread.sleep(5000);
    Object obj = new Object();
    Thread t1 = new Thread(() -> {
        try {
            print("t1 拿锁前", obj);
            synchronized (obj) {
                Thread.sleep(2000);
                print("t1 拿到锁", obj);
            }
            print("t1 释放锁", obj);
        } catch (InterruptedException e) {
            // ignore
        }
    });
    t1.start();
    Thread.sleep(1000);
    Thread t2 = new Thread(() -> {
        print("t2 拿锁前", obj);
        synchronized (obj) {
            print("t2 拿到锁", obj);
        }
        print("t2 释放锁", obj);
    });
    t2.start();
}
```

```

t1 拿锁前				--- 2024-07-30T11:09:58.827
mark word: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
0   8        (object header: mark)     0x0000000000000005 (biasable; age: 0)
8   4        (object header: class)    0xf80001e5
12   4        (object alignment gap)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t2 拿锁前				--- 2024-07-30T11:09:59.831
mark word: 00000000 00000000 00000001 10001000 11010011 11101011 11000000 00000101
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
0   8        (object header: mark)     0x00000188d3ebc005 (biased: 0x000000006234faf0; epoch: 0; age: 0)
8   4        (object header: class)    0xf80001e5
12   4        (object alignment gap)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t1 拿到锁				--- 2024-07-30T11:10:02.319
mark word: 00000000 00000000 00000001 10001000 11010001 01011100 10110101 00001010
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
0   8        (object header: mark)     0x00000188d15cb50a (fat lock: 0x00000188d15cb50a)
8   4        (object header: class)    0xf80001e5
12   4        (object alignment gap)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t1 释放锁				--- 2024-07-30T11:10:02.322
mark word: 00000000 00000000 00000001 10001000 11010001 01011100 10110101 00001010
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
0   8        (object header: mark)     0x00000188d15cb50a (fat lock: 0x00000188d15cb50a)
8   4        (object header: class)    0xf80001e5
12   4        (object alignment gap)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t2 拿到锁				--- 2024-07-30T11:10:02.322
mark word: 00000000 00000000 00000001 10001000 11010001 01011100 10110101 00001010
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
0   8        (object header: mark)     0x00000188d15cb50a (fat lock: 0x00000188d15cb50a)
8   4        (object header: class)    0xf80001e5
12   4        (object alignment gap)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

t2 释放锁				--- 2024-07-30T11:10:02.325
mark word: 00000000 00000000 00000001 10001000 11010001 01011100 10110101 00001010
java.lang.Object object internals:
OFF  SZ   TYPE DESCRIPTION               VALUE
0   8        (object header: mark)     0x00000188d15cb50a (fat lock: 0x00000188d15cb50a)
8   4        (object header: class)    0xf80001e5
12   4        (object alignment gap)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

```

当 t2 尝试获取锁时，锁偏向 t1 并且 t1 还未释放锁，此时发生了竞争，就会升级到 fat lock（重量级锁）

## 参考资料

《深入理解Java虚拟机（第三版）》

[浅析synchronized锁升级的原理与实现 - 小新成长之路 - 博客园 (cnblogs.com)](https://www.cnblogs.com/star95/p/17542850.html)

[盘一盘 synchronized （一）—— 从打印Java对象头说起 - 柠檬五个半 - 博客园 (cnblogs.com)](https://www.cnblogs.com/LemonFive/p/11246086.html)

[Java锁与线程的那些事 (youzan.com)](https://tech.youzan.com/javasuo-yu-xian-cheng-de-na-xie-shi/)

[死磕Synchronized底层实现--概论 · Issue #12 · farmerjohngit/myblog (github.com)](https://github.com/farmerjohngit/myblog/issues/12)