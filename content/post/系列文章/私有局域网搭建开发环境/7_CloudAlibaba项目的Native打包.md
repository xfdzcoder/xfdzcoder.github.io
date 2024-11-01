---
url: /7258102899799007232
title: '私有局域网搭建开发环境其七——SpringCloudAlibaba项目的Native构建'
date: 2024-11-01T21:09:49+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', '私有局域网搭建开发环境', 'kubernetes', 'GraalVM', 'SpringCloud']
---

<hr>

## 作者说

耗时10天的空闲时间终于构建好了第一个模块，怪不得 Native Image 不推荐用于生产环境呢，该模块使用jar包直接运行启动耗时约10s，Native Image启动耗时约4s。其余测试后面再说吧。

通过这次构建 Native Image 的过程也是体会到了有得就会有舍，轻量级和无需预热的代价是动态性，例如配置无法动态刷新的话Nacos配置中心似乎没有什么作用，毕竟直接使用spring的profile也可以做到启动指定配置。

## 参考文献

[走向 Native 化：Spring&Dubbo AOT 技术示例与原理讲解 | Apache Dubbo](https://cn.dubbo.apache.org/zh-cn/blog/2023/06/28/走向-native-化springdubbo-aot-技术示例与原理讲解/)

## 相关官网

[Download GraalVM](https://www.graalvm.org/downloads)

[Native Image](https://www.graalvm.org/latest/reference-manual/native-image/?spm=a2c6h.12873639.article-detail.9.51f151e8AzXUsW#install-native-image)

[用于 GraalVM Native Image 构建的 Maven 插件](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html)

[【避坑+实操】GraalVM、native-image、Visual Studio安装，环境变量的配置，GraalVM的demo初体验_native image 安装包-CSDN博客](https://blog.csdn.net/jpkopkop/article/details/127675664)

```shell
[INFO] -------< io.github.xfdzcoder.noj.cloud.manage:manage-community >--------
[INFO] Building manage-community 1.0.0                                  [16/32]
[INFO]   from manage\manage-community\pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- native:0.10.3:add-reachability-metadata (add-reachability-metadata) @ manage-community ---
[INFO] [graalvm reachability metadata repository for com.mysql:mysql-connector-j:8.3.0]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for com.mysql:mysql-connector-j:8.3.0]: Configuration directory is com.mysql\mysql-connector-j\8.0.31
[INFO] [graalvm reachability metadata repository for com.zaxxer:HikariCP:5.0.1]: Configuration directory is com.zaxxer\HikariCP\5.0.1
[INFO] [graalvm reachability metadata repository for org.jetbrains.kotlin:kotlin-stdlib:1.9.23]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.jetbrains.kotlin:kotlin-stdlib:1.9.23]: Configuration directory is org.jetbrains.kotlin\kotlin-stdlib\1.7.10
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-compress:1.26.2]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-compress:1.26.2]: Configuration directory is org.apache.commons\commons-compress\1.23.0
[INFO] [graalvm reachability metadata repository for jakarta.servlet:jakarta.servlet-api:6.0.0]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for jakarta.servlet:jakarta.servlet-api:6.0.0]: Configuration directory is jakarta.servlet\jakarta.servlet-api\5.0.0
[INFO] [graalvm reachability metadata repository for io.netty:netty-common:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-common:4.1.107.Final]: Configuration directory is io.netty\netty-common\4.1.80.Final
[INFO] [graalvm reachability metadata repository for io.netty:netty-handler:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-handler:4.1.107.Final]: Configuration directory is io.netty\netty-handler\4.1.80.Final
[INFO] [graalvm reachability metadata repository for io.netty:netty-buffer:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-buffer:4.1.107.Final]: Configuration directory is io.netty\netty-buffer\4.1.80.Final
[INFO] [graalvm reachability metadata repository for io.netty:netty-transport:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-transport:4.1.107.Final]: Configuration directory is io.netty\netty-transport\4.1.80.Final
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-pool2:2.12.0]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-pool2:2.12.0]: Configuration directory is org.apache.commons\commons-pool2\2.11.1
[INFO] [graalvm reachability metadata repository for ch.qos.logback:logback-classic:1.4.14]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for ch.qos.logback:logback-classic:1.4.14]: Configuration directory is ch.qos.logback\logback-classic\1.4.9
[INFO] [graalvm reachability metadata repository for com.fasterxml.jackson.core:jackson-databind:2.15.4]: Configuration directory is com.fasterxml.jackson.core\jackson-databind\2.15.2
[INFO] [graalvm reachability metadata repository for org.apache.tomcat.embed:tomcat-embed-core:10.1.19]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.apache.tomcat.embed:tomcat-embed-core:10.1.19]: Configuration directory is org.apache.tomcat.embed\tomcat-embed-core\10.0.20
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Configuration directory is org.hibernate.validator\hibernate-validator\7.0.4.Final
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Latest version not found!
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: missing.
[INFO] [graalvm reachability metadata repository for org.jboss.logging:jboss-logging:3.5.3.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.jboss.logging:jboss-logging:3.5.3.Final]: Configuration directory is org.jboss.logging\jboss-logging\3.5.0.Final
[INFO] [graalvm reachability metadata repository for org.hdrhistogram:HdrHistogram:2.1.12]: Configuration directory is org.hdrhistogram\HdrHistogram\2.1.12
[INFO] [graalvm reachability metadata repository for org.apache.httpcomponents:httpclient:4.5.14]: Configuration directory is org.apache.httpcomponents\httpclient\4.5.14
[INFO]
[INFO] --- resources:3.3.1:resources (default-resources) @ manage-community ---
[INFO] Copying 1 resource from src\main\resources to target\classes
[INFO]
[INFO] --- flatten:1.6.0:flatten (flatten) @ manage-community ---
[INFO] Generating flattened POM of project io.github.xfdzcoder.noj.cloud.manage:manage-community:jar:1.0.0...
[INFO]
[INFO] --- compiler:3.13.0:compile (default-compile) @ manage-community ---
[INFO] Nothing to compile - all classes are up to date.
[INFO]
[INFO] --- resources:3.3.1:testResources (default-testResources) @ manage-community ---
[INFO] skip non existing resourceDirectory D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\src\test\resources
[INFO]
[INFO] --- compiler:3.13.0:testCompile (default-testCompile) @ manage-community ---
[INFO] No sources to compile
[INFO]
[INFO] --- surefire:3.2.2:test (default-test) @ manage-community ---
[WARNING]  Parameter 'systemProperties' is deprecated: Use systemPropertyVariables instead.
[INFO] Tests are skipped.
[INFO]
[INFO] --- native:0.10.3:test (test-native) @ manage-community ---
[INFO] Skipping native-image tests (parameter 'skipTests' or 'skipNativeTests' is true).
[INFO]
[INFO] --- spring-boot:3.2.4:process-aot (process-aot) @ manage-community ---
[INFO]
[INFO] --- jar:3.3.0:jar (default-jar) @ manage-community ---
[INFO] Building jar: D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\manage-community.jar
[INFO]
[INFO] --- spring-boot:3.2.4:repackage (repackage) @ manage-community ---
[INFO] Replacing main artifact D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\manage-community.jar with repackaged archive, adding nested dependencies in BOOT-INF/.
[INFO] The original artifact has been renamed to D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\manage-community.jar.original
[INFO]
[INFO] --- native:0.10.3:compile-no-fork (build-native) @ manage-community ---
[INFO] Found GraalVM installation from JAVA_HOME variable.
[INFO] [graalvm reachability metadata repository for com.mysql:mysql-connector-j:8.3.0]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for com.mysql:mysql-connector-j:8.3.0]: Configuration directory is com.mysql\mysql-connector-j\8.0.31
[INFO] [graalvm reachability metadata repository for com.zaxxer:HikariCP:5.0.1]: Configuration directory is com.zaxxer\HikariCP\5.0.1
[INFO] [graalvm reachability metadata repository for org.jetbrains.kotlin:kotlin-stdlib:1.9.23]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.jetbrains.kotlin:kotlin-stdlib:1.9.23]: Configuration directory is org.jetbrains.kotlin\kotlin-stdlib\1.7.10
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-compress:1.26.2]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-compress:1.26.2]: Configuration directory is org.apache.commons\commons-compress\1.23.0
[INFO] [graalvm reachability metadata repository for jakarta.servlet:jakarta.servlet-api:6.0.0]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for jakarta.servlet:jakarta.servlet-api:6.0.0]: Configuration directory is jakarta.servlet\jakarta.servlet-api\5.0.0
[INFO] [graalvm reachability metadata repository for io.netty:netty-common:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-common:4.1.107.Final]: Configuration directory is io.netty\netty-common\4.1.80.Final
[INFO] [graalvm reachability metadata repository for io.netty:netty-handler:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-handler:4.1.107.Final]: Configuration directory is io.netty\netty-handler\4.1.80.Final
[INFO] [graalvm reachability metadata repository for io.netty:netty-buffer:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-buffer:4.1.107.Final]: Configuration directory is io.netty\netty-buffer\4.1.80.Final
[INFO] [graalvm reachability metadata repository for io.netty:netty-transport:4.1.107.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for io.netty:netty-transport:4.1.107.Final]: Configuration directory is io.netty\netty-transport\4.1.80.Final
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-pool2:2.12.0]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.apache.commons:commons-pool2:2.12.0]: Configuration directory is org.apache.commons\commons-pool2\2.11.1
[INFO] [graalvm reachability metadata repository for ch.qos.logback:logback-classic:1.4.14]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for ch.qos.logback:logback-classic:1.4.14]: Configuration directory is ch.qos.logback\logback-classic\1.4.9
[INFO] [graalvm reachability metadata repository for com.fasterxml.jackson.core:jackson-databind:2.15.4]: Configuration directory is com.fasterxml.jackson.core\jackson-databind\2.15.2
[INFO] [graalvm reachability metadata repository for org.apache.tomcat.embed:tomcat-embed-core:10.1.19]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.apache.tomcat.embed:tomcat-embed-core:10.1.19]: Configuration directory is org.apache.tomcat.embed\tomcat-embed-core\10.0.20
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Configuration directory is org.hibernate.validator\hibernate-validator\7.0.4.Final
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: Latest version not found!
[INFO] [graalvm reachability metadata repository for org.hibernate.validator:hibernate-validator:8.0.1.Final]: missing.
[INFO] [graalvm reachability metadata repository for org.jboss.logging:jboss-logging:3.5.3.Final]: Configuration directory not found. Trying latest version.
[INFO] [graalvm reachability metadata repository for org.jboss.logging:jboss-logging:3.5.3.Final]: Configuration directory is org.jboss.logging\jboss-logging\3.5.0.Final
[INFO] [graalvm reachability metadata repository for org.hdrhistogram:HdrHistogram:2.1.12]: Configuration directory is org.hdrhistogram\HdrHistogram\2.1.12
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-common/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-buffer/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-transport/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-codec/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-handler/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-codec-http/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-transport-classes-epoll/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[WARNING] Properties file at 'jar:file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar!/META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-codec-http2/native-image.properties' does not match the recommended 'META-INF/native-image/com.alibaba.nacos/nacos-client/native-image.properties' layout.
[INFO] [graalvm reachability metadata repository for org.apache.httpcomponents:httpclient:4.5.14]: Configuration directory is org.apache.httpcomponents\httpclient\4.5.14
[INFO] Executing: D:\envs\java\graalvm21\bin\native-image.cmd @target\tmp\native-image-3832139194824435976.args io.github.xfdzcoder.noj.cloud.manage.community.ManageCommunityApplication
Warning: The option '-H:ReflectionConfigurationResources=META-INF/native-image/io.grpc.netty.shaded.io.netty/netty-transport/reflection-config.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: The option '-H:ReflectionConfigurationResources=META-INF/native-image/org.apache.tomcat.embed/tomcat-embed-websocket/tomcat-reflection.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: The option '-H:ReflectionConfigurationResources=META-INF/native-image/org.apache.tomcat.embed/tomcat-embed-el/tomcat-reflection.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: The option '-H:ResourceConfigurationResources=META-INF/native-image/org.apache.tomcat.embed/tomcat-embed-core/tomcat-resource.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: The option '-H:ReflectionConfigurationResources=META-INF/native-image/org.apache.tomcat.embed/tomcat-embed-core/tomcat-reflection.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: The option '-H:ResourceConfigurationResources=META-INF/native-image/org.apache.tomcat.embed/tomcat-embed-el/tomcat-resource.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: The option '-H:ResourceConfigurationResources=META-INF/native-image/org.apache.tomcat.embed/tomcat-embed-websocket/tomcat-resource.json' is experimental and must be enabled via '-H:+UnlockExperimentalVMOptions' in the future.
Warning: Please re-evaluate whether any experimental option is required, and either remove or unlock it. The build output lists all active experimental options, including where they come from and possible alternatives. If you think an experimental option should be considered as stable, please file an issue.
========================================================================================================================
GraalVM Native Image: Generating 'manage-community' (executable)...
========================================================================================================================
For detailed information and explanations on the build output, visit:
https://github.com/oracle/graal/blob/master/docs/reference-manual/native-image/BuildOutput.md
------------------------------------------------------------------------------------------------------------------------
[1/8] Initializing...                                                                                   (26.5s @ 0.28GB)
 Java version: 21.0.5+9-LTS, vendor version: Oracle GraalVM 21.0.5+9.1
 Graal compiler: optimization level: 2, target machine: x86-64-v3, PGO: ML-inferred
 C compiler: cl.exe (microsoft, x64, 19.41.34123)
 Garbage collector: Serial GC (max heap size: 80% of RAM)
 2 user-specific feature(s):
 - com.oracle.svm.thirdparty.gson.GsonFeature
 - org.springframework.aot.nativex.feature.PreComputeFieldFeature
------------------------------------------------------------------------------------------------------------------------
 2 experimental option(s) unlocked:
 - '-H:ResourceConfigurationResources' (origin(s): 'META-INF\native-image\org.apache.tomcat.embed\tomcat-embed-core\native-image.properties' in 'file:///D:/envs/maven/repo/org/apache/tomcat/embed/tomcat-embed-core/10.1.19/tomcat-embed-core-10.1.19.jar', 'META-INF\native-image\org.apache.tomcat.embed\tomcat-embed-websocket\native-image.properties' in 'file:///D:/envs/maven/repo/org/apache/tomcat/embed/tomcat-embed-websocket/10.1.19/tomcat-embed-websocket-10.1.19.jar', 'META-INF\native-image\org.apache.tomcat.embed\tomcat-embed-el\native-image.properties' in 'file:///D:/envs/maven/repo/org/apache/tomcat/embed/tomcat-embed-el/10.1.19/tomcat-embed-el-10.1.19.jar')
 - '-H:ReflectionConfigurationResources' (origin(s): 'META-INF\native-image\org.apache.tomcat.embed\tomcat-embed-core\native-image.properties' in 'file:///D:/envs/maven/repo/org/apache/tomcat/embed/tomcat-embed-core/10.1.19/tomcat-embed-core-10.1.19.jar', 'META-INF\native-image\org.apache.tomcat.embed\tomcat-embed-websocket\native-image.properties' in 'file:///D:/envs/maven/repo/org/apache/tomcat/embed/tomcat-embed-websocket/10.1.19/tomcat-embed-websocket-10.1.19.jar', 'META-INF\native-image\org.apache.tomcat.embed\tomcat-embed-el\native-image.properties' in 'file:///D:/envs/maven/repo/org/apache/tomcat/embed/tomcat-embed-el/10.1.19/tomcat-embed-el-10.1.19.jar', 'META-INF\native-image\io.grpc.netty.shaded.io.netty\netty-transport\native-image.properties' in 'file:///D:/envs/maven/repo/com/alibaba/nacos/nacos-client/2.3.2/nacos-client-2.3.2.jar')
------------------------------------------------------------------------------------------------------------------------
Build resources:
 - 11.88GB of memory (75.6% of 15.71GB system memory, determined at start)
 - 12 thread(s) (100.0% of 12 available processor(s), determined at start)
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
[2/8] Performing analysis...  [******]                                                                  (91.5s @ 2.85GB)
   26,538 reachable types   (90.1% of   29,450 total)
   41,373 reachable fields  (55.4% of   74,707 total)
  146,324 reachable methods (60.5% of  241,806 total)
    9,001 types, 1,219 fields, and 15,711 methods registered for reflection
       90 types,    71 fields, and    77 methods registered for JNI access
        5 native libraries: crypt32, ncrypt, psapi, version, winhttp
[3/8] Building universe...                                                                              (11.1s @ 3.69GB)
[4/8] Parsing methods...      [*****]                                                                   (22.4s @ 2.12GB)
[5/8] Inlining methods...     [****]                                                                     (3.8s @ 3.09GB)
[6/8] Compiling methods...    [***********]                                                            (133.3s @ 3.58GB)
[7/8] Laying out methods...   [*****]                                                                   (26.3s @ 5.33GB)
[8/8] Creating image...       [*****]                                                                   (27.6s @ 3.32GB)
  75.39MB (58.23%) for code area:    88,557 compilation units
  53.18MB (41.07%) for image heap:  612,314 objects and 370 resources
 915.83kB ( 0.69%) for other data
 129.46MB in total
------------------------------------------------------------------------------------------------------------------------
Top 10 origins of code area:                                Top 10 object types in image heap:
  17.88MB java.base                                           20.76MB byte[] for code metadata
   8.09MB nacos-client-2.3.2.jar                               9.33MB byte[] for java.lang.String
   6.25MB svm.jar (Native Image)                               5.04MB java.lang.Class
   4.28MB java.xml                                             4.40MB java.lang.String
   3.57MB jdk.proxy4                                           2.12MB byte[] for reflection metadata
   2.96MB lettuce-core-6.3.2.RELEASE.jar                       1.59MB byte[] for embedded resources
   2.76MB spring-data-redis-3.2.4.jar                          1.21MB com.oracle.svm.core.hub.DynamicHubCompanion
   2.66MB mysql-connector-j-8.3.0.jar                        990.00kB java.lang.reflect.Method
   2.40MB jackson-databind-2.15.4.jar                        969.26kB byte[] for general heap data
   2.14MB tomcat-embed-core-10.1.19.jar                      759.31kB c.o.svm.core.hub.DynamicHub$ReflectionMetadata
  21.77MB for 135 more packages                                6.07MB for 4752 more object types
                              Use '-H:+BuildReport' to create a report with more details.
------------------------------------------------------------------------------------------------------------------------
Security report:
 - Binary includes Java deserialization.
 - Use '--enable-sbom' to embed a Software Bill of Materials (SBOM) in the binary.
 - The log4j library has been detected, but the version is unavailable. Due to Log4Shell, please ensure log4j is at version 2.17.1 or later.
------------------------------------------------------------------------------------------------------------------------
Recommendations:
 PGO:  Use Profile-Guided Optimizations ('--pgo') for improved throughput.
 INIT: Adopt '--strict-image-heap' to prepare for the next GraalVM release.
 HEAP: Set max heap for improved and more predictable memory usage.
 CPU:  Enable more CPU features with '-march=native' for improved performance.
 QBM:  Use the quick build mode ('-Ob') to speed up builds during development.
------------------------------------------------------------------------------------------------------------------------
                       50.2s (14.5% of total time) in 259 GCs | Peak RSS: 6.86GB | CPU load: 5.50
------------------------------------------------------------------------------------------------------------------------
Produced artifacts:
 D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\instrument.dll (jdk_library)
 D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\jaas.dll (jdk_library)
 D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\manage-community.exe (executable)
 D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\w2k_lsa_auth.dll (jdk_library)
========================================================================================================================
Finished generating 'manage-community' in 5m 45s.
```



## 问题

### 问题1：No spring.config.import property has been defined

```
❯ .\manage-community.exe
22:02:14.743 [main] ERROR org.springframework.boot.diagnostics.LoggingFailureAnalysisReporter --

***************************
APPLICATION FAILED TO START
***************************

Description:

No spring.config.import property has been defined

Action:

Add a spring.config.import=nacos: property to your configuration.
        If configuration is not required add spring.config.import=optional:nacos: instead.
        To disable this check, set spring.cloud.nacos.config.import-check.enabled=false.
```

bootstrap.yml

```yml
server:
  port: 5041
  servlet:
    context-path: /community
spring:
  application:
    name: community
  cloud:
    nacos:
      server-addr: ${nacos.server-addr}:${nacos.port}
      username: ${nacos.username}
      password: ${nacos.password}
      config:
        file-extension: ${nacos.file-extension}
        group: ${nacos.manage-group}
        namespace: ${nacos.namespace}
        shared-configs:
          - data-id: redis.yml
            refresh: true
            group: ${nacos.common-group}
          - data-id: mysql.yml
            refresh: true
            group: ${nacos.common-group}
      discovery:
        group: ${nacos.manage-group}
        namespace: ${nacos.namespace}
  config:
    import: optional:none
```

#### 解决

按照提示指定启动参数：

```
❯ .\manage-community --spring.config.additional-location=D:\projects\work\xfdzcoder\NOJ\noj-cloud\conf\config-dev.yml --spring.config.import=optional:nacos:instead
```

### 问题2：构建后缺失 ServletWebServerFactory

```
❯ .\target\manage-community.exe --spring.config.import=optional:nacos:instead                                                                                                 
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.4)

2024-10-24T19:22:26.676+08:00  INFO 20784 --- [           main] i.g.x.n.c.m.c.ManageCommunityApplication : Starting AOT-processed ManageCommunityApplication using Java 21.0.5 with PID 20784 (D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community\target\manage-community.exe started by xfdz in D:\projects\work\xfdzcoder\NOJ\noj-cloud\manage\manage-community)
2024-10-24T19:22:26.676+08:00  INFO 20784 --- [           main] i.g.x.n.c.m.c.ManageCommunityApplication : No active profile set, falling back to 1 default profile: "default"
2024-10-24T19:22:26.676+08:00  WARN 20784 --- [           main] c.a.c.n.c.NacosConfigDataLoader          : [Nacos Config] config[dataId=instead, group=DEFAULT_GROUP] is empty
2024-10-24T19:22:26.677+08:00  WARN 20784 --- [           main] w.s.c.ServletWebServerApplicationContext : Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException: Unable to start web server
2024-10-24T19:22:26.677+08:00 ERROR 20784 --- [           main] o.s.b.d.LoggingFailureAnalysisReporter   :

***************************
APPLICATION FAILED TO START
***************************

Description:

Web application could not be started as there was no org.springframework.boot.web.servlet.server.ServletWebServerFactory bean defined in the context.

Action:

Check your application's dependencies for a supported servlet web server.
Check the configured web application type.
```

#### 解决

不能使用bootstrap，需要使用spring.config.import导入

### 问题3：Failed to generate code for RefreshScope

```
Exception in thread "main" java.lang.IllegalArgumentException: Failed to generate code for 'org.springframework.cloud.context.scope.refresh.RefreshScope@6093d508' with type org.springframework.cloud.context.scope.refresh.RefreshScope
```

#### 解决

```yml
spring:
  cloud:
    refresh:
      enabled: false
```

### 问题4：communityInfoMapper和MapperFactoryBean的bean定义冲突

```
org.springframework.context.annotation.ConflictingBeanDefinitionException: Annotation-specified bean name 'communityInfoMapper' for bean class [io.github.xfdzcoder.noj.cloud.manage.community.mapper.CommunityInfoMapper] conflicts with existing, non-compatible bean definition of same name and class [org.mybatis.spring.mapper.MapperFactoryBean]
```

#### 解决

[spring-boot+native-image+整合myabtis-plus、spring-security_mybatis native-image-CSDN博客](https://blog.csdn.net/asddd44/article/details/137240340)

[SpringBoot3支持问题 · Issue #5527 · baomidou/mybatis-plus](https://github.com/baomidou/mybatis-plus/issues/5527)

### 问题5：ServerCheckResponse.setSupportAbilityNegotiation(boolean) without it being registered for runtime reflection

```
2024-10-31T21:14:47.983+08:00  WARN 31708 --- [community] [           main] com.alibaba.nacos.common.remote.client   : [180612eb-b1c7-4a72-88d2-249b14fc773a] Fail to connect to server on start up, error message = The program tried to reflectively inv
oke method public void com.alibaba.nacos.api.remote.response.ServerCheckResponse.setSupportAbilityNegotiation(boolean) without it being registered for runtime reflection. Add public void com.alibaba.nacos.api.remote.response.ServerCheckResponse.setSupportAbilityNegotiation(boolean) to the reflection metadata to solve this problem. See https://www.graalvm.org/latest/reference-manual/native-image/metadata/#reflection for help., start up retry times left: -1

org.graalvm.nativeimage.MissingReflectionRegistrationError: The program tried to reflectively invoke method public void com.alibaba.nacos.api.remote.response.ServerCheckResponse.setSupportAbilityNegotiation(boolean) without it being registered for ru
ntime reflection. Add public void com.alibaba.nacos.api.remote.response.ServerCheckResponse.setSupportAbilityNegotiation(boolean) to the reflection metadata to solve this problem. See https://www.graalvm.org/latest/reference-manual/native-image/metadata/#reflection for help.
```

#### 解决

[grallvm 原生镜像 com.alibaba.nacos.api.remote.response.ServerCheckResponse MissingReflectionRegistrationError ·问题 #12688 ·阿里巴巴/NACOS](https://github.com/alibaba/nacos/issues/12688)	

### 问题6：无法连接 Nacos

```
2024-10-31T22:48:52.881+08:00  INFO 36860 --- [community] [           main] com.alibaba.nacos.client.naming          : Create naming rpc client for uuid->0885d21e-a9e0-4107-bad1-e389c1fb94f3
2024-10-31T22:48:52.881+08:00  INFO 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : [0885d21e-a9e0-4107-bad1-e389c1fb94f3] RpcClient init, ServerListFactory = com.alibaba.nacos.client.naming.core.ServerListManager  
2024-10-31T22:48:52.882+08:00  INFO 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : [0885d21e-a9e0-4107-bad1-e389c1fb94f3] Registry connection listener to current client:com.alibaba.nacos.client.naming.remote.gprc.redo.NamingGrpcRedoService
2024-10-31T22:48:52.882+08:00  INFO 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : [0885d21e-a9e0-4107-bad1-e389c1fb94f3] Register server push request handler:com.alibaba.nacos.client.naming.remote.gprc.NamingPushRequestHandler
2024-10-31T22:48:52.882+08:00  INFO 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : [0885d21e-a9e0-4107-bad1-e389c1fb94f3] Try to connect to server on start up, server: {serverIp = '172.24.0.2', server main port = 4404}
2024-10-31T22:48:52.882+08:00  INFO 36860 --- [community] [           main] c.a.n.c.remote.client.grpc.GrpcClient    : grpc client connection server:172.24.0.2 ip,serverPort:5404,grpcTslConfig:{"sslProvider":"","enableTls":false,"mutualAuthEnable":false,"trustAll":false}
2024-10-31T22:48:53.049+08:00  WARN 36860 --- [community] [or-172.24.0.2-6] c.a.n.c.remote.client.grpc.GrpcClient    : [1730386133685_172.24.0.1_6289]Ignore error event,isRunning:false,isAbandon=false
2024-10-31T22:48:54.874+08:00 ERROR 36860 --- [community] [remote.worker.0] c.a.n.c.remote.client.grpc.GrpcClient    : Client don't receive server abilities table even empty table but server supports ability negotiation. You can check if it is need to adjust the timeout of ability negotiation by property: nacos.remote.client.grpc.channel.capability.negotiation.timeout if always fail to connect.
```

```
2024-10-31T22:49:13.479+08:00  INFO 36860 --- [community] [remote.worker.0] c.a.n.c.remote.client.grpc.GrpcClient    : grpc client connection server:172.24.0.2 ip,serverPort:5404,grpcTslConfig:{"sslProvider":"","enableTls":false,"mutualAuthEnable":false,"trustAll":false}
2024-10-31T22:49:13.589+08:00 ERROR 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : Send request fail, request = InstanceRequest{headers={accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTczMDQwNDEzM30.HpXbUhZoEX6Y2nGm4w_nNDXP3qJxkHqRYvq2hTeg118, app=unknown}, requestId='null'}, retryTimes = 0, errorMessage = Client not connected, current status:STARTING
2024-10-31T22:49:13.672+08:00  WARN 36860 --- [community] [r-172.24.0.2-34] c.a.n.c.remote.client.grpc.GrpcClient    : [1730386154305_172.24.0.1_6333]Ignore error event,isRunning:false,isAbandon=false
2024-10-31T22:49:13.698+08:00 ERROR 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : Send request fail, request = InstanceRequest{headers={accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTczMDQwNDEzM30.HpXbUhZoEX6Y2nGm4w_nNDXP3qJxkHqRYvq2hTeg118, app=unknown}, requestId='null'}, retryTimes = 1, errorMessage = Client not connected, current status:STARTING
2024-10-31T22:49:13.808+08:00 ERROR 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : Send request fail, request = InstanceRequest{headers={accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTczMDQwNDEzM30.HpXbUhZoEX6Y2nGm4w_nNDXP3qJxkHqRYvq2hTeg118, app=unknown}, requestId='null'}, retryTimes = 2, errorMessage = Client not connected, current status:STARTING
2024-10-31T22:49:13.918+08:00 ERROR 36860 --- [community] [           main] com.alibaba.nacos.common.remote.client   : Send request fail, request = InstanceRequest{headers={accessToken=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuYWNvcyIsImV4cCI6MTczMDQwNDEzM30.HpXbUhZoEX6Y2nGm4w_nNDXP3qJxkHqRYvq2hTeg118, app=unknown}, requestId='null'}, retryTimes = 3, errorMessage = Client not connected, current status:STARTING
2024-10-31T22:49:13.919+08:00 ERROR 36860 --- [community] [           main] c.a.c.n.registry.NacosServiceRegistry    : nacos registry, community register failed...NacosRegistration{nacosDiscoveryProperties=NacosDiscoveryProperties{serverAddr='172.24.
0.2:4404', username='nacos', password='wxzxgsybD_P258852', endpoint='', namespace='5003c224-1a0f-4d34-b02c-5942e451f893', watchDelay=30000, logName='', service='community', weight=1.0, clusterName='DEFAULT', group='MANAGE_GROUP', namingLoadCacheAtSta
rt='false', metadata={preserved.register.source=SPRING_CLOUD}, registerEnabled=true, ip='172.24.0.1', networkInterface='', port=8080, secure=false, accessKey='', secretKey='', heartBeatInterval=null, heartBeatTimeout=null, ipDeleteTimeout=null, instanceEnabled=true, ephemeral=true, failureToleranceEnabled=false}, ipDeleteTimeout=null, failFast=true}},

com.alibaba.nacos.api.exception.NacosException: Client not connected, current status:STARTING
```

#### 解决

需要添加如下配置中的jvmArguments部分，之前参考的是spring-boot-starter-parent里的配置，添加jvmArguments之后重新构建即可。

```
<profiles>
        <profile>
            <id>native</id>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-jar-plugin</artifactId>
                        <configuration>
                            <archive>
                                <manifestEntries>
                                    <Spring-Boot-Native-Processed>true</Spring-Boot-Native-Processed>
                                </manifestEntries>
                            </archive>
                        </configuration>
                    </plugin>
                    <plugin>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-maven-plugin</artifactId>
                        <configuration>
                            <jvmArguments>
                                -agentlib:native-image-agent=config-output-dir=src/main/resources/META-INF/native-image/,experimental-conditional-config-filter-file=src/main/resources/conditional-filter.json,access-filter-file=src/main/resources/user-code-filter.json
                                <!-- 被认为包含在这个过滤器中的类将被指定为用户代码类 -->
                                <!--experimental-conditional-config-filter-file=src/main/resources/user-code-filter.json,-->
                                <!-- 要进一步过滤生成的配置 -->
                                <!-- conditional-config-class-filter-file=<path> -->
                                <!-- 访问过滤器适用于访问的目标。因此，访问过滤器可以直接从生成的配置中排除包和类（及其成员）。 -->
                                <!--access-filter-file=src/main/resources/conditional-filter.json-->
                                <!-- 过滤机制通过识别执行访问的 Java 方法（也称为调用方方法）并将其声明类与一系列过滤规则相匹配来工作 -->
                                <!--caller-filter-file=src/main/resources/-->
                            </jvmArguments>
                            <image>
                                <builder>paketobuildpacks/builder-jammy-tiny:latest</builder>
                                <env>
                                    <BP_NATIVE_IMAGE>true</BP_NATIVE_IMAGE>
                                </env>
                            </image>
                        </configuration>
                        <executions>
                            <execution>
                                <id>process-aot</id>
                                <goals>
                                    <goal>process-aot</goal>
                                </goals>
                            </execution>
                        </executions>
                    </plugin>
                    <plugin>
                        <groupId>org.graalvm.buildtools</groupId>
                        <artifactId>native-maven-plugin</artifactId>
                        <configuration>
                            <classesDirectory>${project.build.outputDirectory}</classesDirectory>
                            <metadataRepository>
                                <enabled>true</enabled>
                            </metadataRepository>
                            <requiredVersion>22.3</requiredVersion>
                        </configuration>
                        <executions>
                            <execution>
                                <id>add-reachability-metadata</id>
                                <goals>
                                    <goal>add-reachability-metadata</goal>
                                </goals>
                            </execution>
                        </executions>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
```