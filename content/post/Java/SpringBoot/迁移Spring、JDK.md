---
url: /7229066755950288896
title: '升级到SpringBoot3、JDK21'
date: 2024-08-13T18:10:37+08:00
draft: false
summary: ""
categories: [Java]
tags: ['springboot', '升级指南']
---

<hr>

迁移指南：

[Spring-Boot-3.0-Migration-Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)



## Spring 方面

### 1. URL 映射更改

>#### Spring MVC and WebFlux URL Matching Changes
>
>
>
>As of Spring Framework 6.0, the trailing slash matching configuration option has been deprecated and its default value set to `false`. This means that previously, the following controller would match both "GET /some/greeting" and "GET /some/greeting/":
>
>```java
>@RestController
>public class MyController {
>
>  @GetMapping("/some/greeting")
>  public String greeting() {
>    return "Hello";
>  }
>
>}
>```
>
>As of [this Spring Framework change](https://github.com/spring-projects/spring-framework/issues/28552), "GET /some/greeting/" doesn’t match anymore by default and will result in an HTTP 404 error.
>
>Developers should instead configure explicit redirects/rewrites through a proxy, a Servlet/web filter, or even declare the additional route explicitly on the controller handler (like `@GetMapping("/some/greeting", "/some/greeting/")` for more targeted cases.
>
>Until your application fully adapts to this change, you can change the default with the following global Spring MVC configuration:
>
>```java
>@Configuration
>public class WebConfiguration implements WebMvcConfigurer {
>
>    @Override
>    public void configurePathMatch(PathMatchConfigurer configurer) {
>      configurer.setUseTrailingSlashMatch(true);
>    }
>
>}
>```
>
>Or if you’re using Spring WebFlux:
>
>```java
>@Configuration
>public class WebConfiguration implements WebFluxConfigurer {
>
>    @Override
>    public void configurePathMatching(PathMatchConfigurer configurer) {
>      configurer.setUseTrailingSlashMatch(true);
>    }
>
>}
>```

过去：`"/some/greeting"` 和 `"/some/greeting/"` 是一样的

```java
@RestController
public class MyController {

  @GetMapping("/some/greeting")
  public String greeting() {
    return "Hello";
  }

}
```

现在：`"/some/greeting"` 和 `"/some/greeting/"` 是两个不同的路径。

或者，通过如下方式来恢复到过去的匹配方式：

```java
// MVC
@Configuration
public class WebConfiguration implements WebMvcConfigurer {

    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
      configurer.setUseTrailingSlashMatch(true);
    }

}

// WebFlux
@Configuration
public class WebConfiguration implements WebFluxConfigurer {

    @Override
    public void configurePathMatching(PathMatchConfigurer configurer) {
      configurer.setUseTrailingSlashMatch(true);
    }

}
```

### 2. server.max-http-header-size

> Previously, the `server.max-http-header-size` was treated inconsistently across the four supported embedded web servers. When using Jetty, Netty, or Undertow it would configure the max HTTP request header size. When using Tomcat it would configure the max HTTP request and response header sizes.
> 以前，`server.max-http-header-size`在四个受支持的嵌入式 Web 服务器中，处理方式不一致。当使用 Jetty、Netty 或 Undertow 时，它将配置最大 HTTP 请求标头大小。当使用 Tomcat 时，它将配置最大 HTTP 请求和响应标头大小。
>
> To address this inconsistency, `server.max-http-header-size` has been deprecated and a replacement, `server.max-http-request-header-size`, has been introduced. Both properties now only apply to the request header size, irrespective of the underlying web server.
> 为了解决这种不一致问题， `server.max-http-header-size`已被弃用，并引入了替代品 `server.max-http-request-header-size`。这两个属性现在仅适用于请求标头大小，而与底层 Web 服务器无关。
>
> To limit the max header size of an HTTP response on Tomcat or Jetty (the only two servers that support such a setting), use a `WebServerFactoryCustomizer`.
> 要限制 Tomcat 或 Jetty（仅有的两个支持此类设置的服务器）上的 HTTP 响应的最大标头大小，请使用 `WebServerFactoryCustomizer`。

### 3. Jetty

> Jetty does not yet support Servlet 6.0. To use Jetty with Spring Boot 3.0, you will have to downgrade the Servlet API to 5.0. You can use the `jakarta-servlet.version` property to do so.
> Jetty 尚不支持 Servlet 6.0。要将 Jetty 与 Spring Boot 3.0 一起使用，您必须将 Servlet API 降级到 5.0。您可以使用 `jakarta-servlet.version`这样做的财产。

### 4. Apache HttpClient in RestTemplate

> Support for Apache HttpClient has been [removed in Spring Framework 6.0](https://github.com/spring-projects/spring-framework/issues/28925), immediately replaced by `org.apache.httpcomponents.client5:httpclient5` (note: this dependency has a different groupId). If you are noticing issues with HTTP client behavior, it could be that `RestTemplate` is falling back to the JDK client. `org.apache.httpcomponents:httpclient` can be brought transitively by other dependencies, so your application might rely on this dependency without declaring it.
>
> 对 Apache HttpClient 的支持[已在 Spring Framework 6.0 中删除](https://github.com/spring-projects/spring-framework/issues/28925)，并立即替换为 `org.apache.httpcomponents.client5:httpclient5` （注意：此依赖项具有不同的 groupId）。如果您注意到 HTTP 客户端行为存在问题，可能是 `RestTemplate` 正在回退到 JDK 客户端。  `org.apache.httpcomponents:httpclient` 可以由其他依赖项传递传递，因此您的应用程序可能依赖此依赖项而不声明它。

### 5. Redis Properties

> Configuration Properties for Redis have moved from `spring.redis.` to `spring.data.redis.` as redis auto-configuration requires Spring Data to be present on the classpath.
> Redis 的配置属性已从 `spring.redis.` 移至到 `spring.data.redis。`因为 redis 自动配置要求 Spring Data 存在于类路径中。

### 6. Elasticsearch Clients and Templates Elasticsearch

> Support for Elasticsearch’s high-level REST client has been removed. In its place, auto-configuration for Elasticsearch’s new Java client has been introduced. Similarly, support for the Spring Data Elasticsearch templates that built on top of the high-level REST client has been removed. In its place, auto-configuration for the new templates that build upon the new Java client has been introduced. See [the Elasticsearch section of the reference documentation](https://docs.spring.io/spring-boot/docs/3.0.x/reference/html/data.html#data.nosql.elasticsearch) for further details.
> 对 Elasticsearch 的高级 REST 客户端的支持已被删除。取而代之的是，引入了 Elasticsearch 的新 Java 客户端的自动配置。同样，对构建在高级 REST 客户端之上的 Spring Data Elasticsearch 模板的支持也已被引入。已删除。取而代之的是，引入了基于新 Java 客户端构建的新模板的自动配置。请参阅 [参考文档的 Elasticsearch 部分 ](https://docs.spring.io/spring-boot/docs/3.0.x/reference/html/data.html#data.nosql.elasticsearch)了解更多详情。
>
> `ReactiveElasticsearchRestClientAutoConfiguration` has been renamed to `ReactiveElasticsearchClientAutoConfiguration` and has moved from `org.springframework.boot.autoconfigure.data.elasticsearch` to `org.springframework.boot.autoconfigure.elasticsearch`. Any auto-configuration exclusions or ordering should be updated accordingly.
> `ReactiveElasticsearchRestClientAutoConfiguration`已重命名为 `ReactiveElasticsearchClientAutoConfiguration`并已从 `org.springframework.boot.autoconfigure.data.elasticsearch` 移至到 `org.springframework.boot.autoconfigure.elasticsearch`。任何自动配置排除或排序都应相应更新。

### 7. MySQL JDBC Driver

> The coordinates of the MySQL JDBC driver have changed from `mysql:mysql-connector-java` to `com.mysql:mysql-connector-j`. If you are using the MySQL JDBC driver, update its coordinates accordingly when upgrading to Spring Boot 3.0.
> MySQL JDBC 驱动程序的坐标已从 `mysql:mysql-connector-java` 更改为到 `com.mysql:mysql-connector-j`。如果您使用 MySQL JDBC 驱动程序，请在升级到 Spring Boot 3.0 时相应更新其坐标。

### 8. Parameter Name Retention

> `LocalVariableTableParameterNameDiscoverer` has been removed in 6.1. Consequently, code within the Spring Framework and Spring portfolio frameworks no longer attempts to deduce parameter names by parsing bytecode. If you experience issues with dependency injection, property binding, SpEL expressions, or other use cases that depend on the names of parameters, you should compile your Java sources with the common Java 8+ `-parameters` flag for parameter name retention (instead of relying on the `-debug` compiler flag) in order to be compatible with `StandardReflectionParameterNameDiscoverer`. The Groovy compiler also supports a `-parameters` flag for the same purpose. With the Kotlin compiler, use the `-java-parameters` flag.
> `LocalVariableTableParameterNameDiscoverer`已在 6.1 中删除。因此，Spring 框架和 Spring 组合框架中的代码不再尝试通过解析字节码来推断参数名称。如果您遇到依赖项注入、属性绑定、SpEL 表达式或其他依赖于参数名称的用例的问题，您应该使用常见的 Java 8+ `-parameters` 来编译 Java 源代码。参数名称保留标志（而不是依赖 `-debug` 编译器标志），以便与 `StandardReflectionParameterNameDiscoverer` 兼容。 Groovy 编译器还支持 `-parameters`出于相同目的的标志。对于 Kotlin 编译器，请使用 `-java-parameters`旗帜。
>
> Maven users need to configure the `maven-compiler-plugin` for Java source code:
> Maven用户需要配置`maven-compiler-plugin`对于Java源代码：
>
> ```xml
> <plugin>
>     <groupId>org.apache.maven.plugins</groupId>
>     <artifactId>maven-compiler-plugin</artifactId>
>     <configuration>
>         <parameters>true</parameters>
>     </configuration>
> </plugin>
> ```

## JDK 方面





