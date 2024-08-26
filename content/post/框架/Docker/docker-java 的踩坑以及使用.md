---
url: /7231855485589168128
title: 'docker-java 的踩坑以及使用'
date: 2024-08-21T10:51:54+08:00
draft: false
summary: '关于回表的疑问'
categories: [Docker]
tags: ['docker']
---

## 参考文献

[官方文档-快速入门](https://github.com/docker-java/docker-java/blob/main/docs/getting_started.md)

[Docker Engine API (1.46)](https://docs.docker.com/engine/api/v1.46/)

## 1. 容器创建完之后立即关闭了

这是正常的，需要手动执行一个不会结束的命令来让容器一直运行，比如 `tail -f /dev/null`

```java
        String containerId = dockerClient.createContainerCmd("jre21")
                .withName("sandbox_java_" + executeInfo.getId())
                .withHostConfig(
                        HostConfig.newHostConfig()
                                .withNetworkMode("none")
                                .withAutoRemove(true)
                                // 单位 Byte
                                .withMemory((long) executeInfo.getMemory())
                                .withBinds(new Bind(classDir, new Volume("/sandbox")))
                                .withCpuShares(1024)
                )
                .withNetworkDisabled(true)
                .withCmd("tail", "-f", "/dev/null")
                .exec()
                .getId();
```

## 2. 执行命令时的输入输出问题

现在参考这个示例：我们需要通过 `docker-java` 来操作Docker，即创建容器、启动容器、创建命令、执行命令。并且在执行命令时向标准输入流写入输入参数，执行结束后获取标准输出流和标准错误输出流。被执行的命令是 `time -f '%e %M %x' java Main` 。

`time` 命令详解：[在Linux上，使用time优雅的统计程序运行时间-腾讯云开发者社区-腾讯云 (tencent.com)](https://cloud.tencent.com/developer/article/1825586)

`Main.java` 源代码如下：

```java
import java.util.Scanner;
public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int a = scanner.nextInt();
        int b = scanner.nextInt();
        System.out.println("a + b = " + (a + b));
        int c = scanner.nextInt();
        int d = scanner.nextInt();
        System.out.println("c + d = " + (c + d));
    }
}
```

首先需要确保创建命令时允许附加相应的流，如下：

```java
        return dockerClient.execCreateCmd(containerId)
                .withWorkingDir(WORKING_DIR)
                .withCmd("time", "-f", "%e %M %x", "java", "Main")
            	// 附加标准流
                .withAttachStdin(Boolean.TRUE)
                .withAttachStdout(Boolean.TRUE)
                .withAttachStderr(Boolean.TRUE)
                .exec()
                .getId();
```

然后需要在执行时对流进行处理：

```java
		// 这里的 input 是一个输入参数，通过标准输入流提供给被运行的 Java 程序
		ByteArrayInputStream stdIn = new ByteArrayInputStream(input.getBytes(StandardCharsets.UTF_8));
        ByteArrayOutputStream stdout = new ByteArrayOutputStream();
        ByteArrayOutputStream stderr = new ByteArrayOutputStream();
        boolean finished = false;
        try {
            finished = dockerClient.execStartCmd(execId)
                    .withStdIn(stdIn)
                    .exec(new ResultCallback.Adapter<>() {
                        @Override
                        public void onStart(Closeable stream) {
                            super.onStart(stream);
                        }

                        @Override
                        public void onNext(Frame frame) {
                            try {
                                switch (frame.getStreamType()) {
                                    case STDOUT -> stdout.write(frame.getPayload());
                                    case STDERR -> stderr.write(frame.getPayload());
                                }
                            } catch (IOException e) {
                                throw new ExecuteException(e);
                            }
                        }
                    })
                    .awaitCompletion(executeInfo.getTimeout(), TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            // ignore
            log.warn(ExceptionUtil.stacktraceToOneLineString(e));
        }
```

注意对流的处理。其中需要注意的是：不能使用 `withTty(true)` ，创建/执行命令的时候都不能，原因如下：

https://docs.docker.com/engine/api/v1.46/#tag/Container/operation/ContainerAttach

>### Stream format when using a TTY
>
>When the TTY setting is enabled in [`POST /containers/create`](https://docs.docker.com/engine/api/v1.46/#operation/ContainerCreate), the stream is not multiplexed. The data exchanged over the hijacked connection is simply the raw data from the process PTY and client's `stdin`.
>
>
>
>使用TTY时的流格式
>当在POST/containers/create中启用TTY设置时，流不会被复用。通过被劫持的连接交换的数据只是来自进程PTY和客户端stdin的原始（RAW）数据。

也就是在 `onNext()` 中不会区分是输入还是输出，`frame.getStreamType()` 始终返回 `RAW` 。

###  未解决的问题

#### 1. time 命令的输出被重定向到了 stderr 中，难道不是应该在 stdout 中吗。

但是也有解决办法：即通过 > 将其重定向，修改后的命令如下：

`sh -c "(time -f '%e %M %x' java Main) 2>&1"`

如果你的环境有 bash，那么可以使用 bash。

#### 2. `stdin` 和 `stdout` 中换行符的转换

使用 TTY 时：（由于使用了 TTY，所以都是通过 RAW 的类型接收数据

- stdin 中的 \n，在接收时会转成\r\n
- stdin 中的 \r\n，在接收时会转成 \r\n\r\n

不使用 TTY 时，没法接收到 stdin 的数据。