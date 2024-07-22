---
title: 'SpringBoot+MybatisPlus快速入门'

date: 2024-07-22T20:01:48+08:00

draft: false

summary: "快速从 Java 基础到 SpringBoot 后端开发"

categories: [Java]
---

<hr>

## 0 准备工作

需要准备的软件/环境：

- JDK1.8
- IDEA
  - 我的是2024.1版，可能界面有所不同，但相差无几
- Maven 3.x
- 一台可上网的电脑

配置：

略

## 1 新建项目

### 1.1 打开新建项目页面

### IDEA: File > New > Project...

![image-20240722200718950](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-07-39-ff3c8defaa2f8940886243ee2382453a-image-20240722200718950-66b973.png)

### 1.2 选择 SpringBoot 并填写项目配置

暂未填写配置时：

![image-20240722200820908](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-08-21-08abd1f6f218ce469551a50cb4a30da9-image-20240722200820908-efcf61.png)

配置说明：

![image-20240722201410954](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-14-11-0cbe4a34275b9a999da7e3a02e1b1016-image-20240722201410954-e06ef7.png)

配置示例：

![image-20240722201457424](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-14-58-b5da9108709a914b28eab7468a89a749-image-20240722201457424-65d02a.png)

### 1.3 选择 springboot 版本和依赖版本

SpringBoot 版本一般选择 2.7.6，或者 2.x.x 的最高版本，不要选择 3.x.x 的

![image-20240722201555155](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-15-56-adb7f684a11c3ad294915721d0516e48-image-20240722201555155-c983f4.png)

## 2 添加必备依赖

这里列出了部分常用的依赖项，可直接将 `pom.xml` 中的 `<properties> ` `<dependencies>` 标签进行替换。记得关注其中的 TODO 注释标签，根据你的 MySQL 版本修改对应的依赖版本。

```xml
	<properties>
        <java.version>1.8</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <spring-boot.version>2.7.6</spring-boot.version>

        <lombok.version>1.18.30</lombok.version>
        <hutool.version>5.8.22</hutool.version>
        <mybatis-plus.version>3.5.3.2</mybatis-plus.version>
        <!-- TODO 根据 MySQL 版本修改 -->
        <mysql.version>8.0.33</mysql.version>
        <druid.version>1.2.19</druid.version>
        <swagger-annotations.version>2.2.9</swagger-annotations.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!--
            代码生成的类库
        -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>${lombok.version}</version>
        </dependency>

        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
            <version>${hutool.version}</version>
        </dependency>

        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>${mybatis-plus.version}</version>
        </dependency>


        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql.version}</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid-spring-boot-starter</artifactId>
            <version>${druid.version}</version>
        </dependency>

        <dependency>
            <groupId>io.swagger.core.v3</groupId>
            <artifactId>swagger-annotations</artifactId>
            <version>${swagger-annotations.version}</version>
        </dependency>

        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt</artifactId>
            <version>0.12.5</version>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
    </dependencies>
```

## 3 创建数据库表

这里就用一个 `student` 表来做示例。

```sql
CREATE DATABASE springboot_demo;

USE springboot_demo;

CREATE TABLE student
(

    id               BIGINT PRIMARY KEY COMMENT '主键',
    student_no         INT COMMENT '学生编号',
    student_name       VARCHAR(50) COMMENT '学生姓名',
    gender             VARCHAR(10) COMMENT '性别',
    age                INT COMMENT '年龄',
    enrollment_year    INT COMMENT '入学年份'
) COMMENT ='学生信息表';
```

通过 IDEA 连接至数据库，首先打开 IDEA 右侧工具栏的 database，点击左上角 + 号，选择 MySQL，输入你的 MySQL 信息并测试连接，测试成功后即可应用。

应用后 IDEA 会默认打开一个控制台，请复制上述 SQL 语句到控制台中执行。

## 4 添加代码生成器插件

插件名称：EasyCode

![image-20240722202739758](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-27-40-77f659a4463632778f634e655d8e88d6-image-20240722202739758-827f87.png)

打开 IDEA 的设置，选择其他设置，然后选择 EasyCode，复制下方配置，并点击从剪切板导入

```json
{
  "author" : "makejava",
  "version" : "1.2.8",
  "userSecure" : "",
  "currTypeMapperGroupName" : "Default",
  "currTemplateGroupName" : "MybatisPlus",
  "currColumnConfigGroupName" : "Default",
  "currGlobalConfigGroupName" : "Default",
  "typeMapper" : {
    "Default" : {
      "name" : "Default",
      "elementList" : [ {
        "matchType" : "REGEX",
        "columnType" : "varchar(\\(\\d+\\))?",
        "javaType" : "java.lang.String"
      }, {
        "matchType" : "REGEX",
        "columnType" : "char(\\(\\d+\\))?",
        "javaType" : "java.lang.String"
      }, {
        "matchType" : "REGEX",
        "columnType" : "(tiny|medium|long)*text",
        "javaType" : "java.lang.String"
      }, {
        "matchType" : "REGEX",
        "columnType" : "decimal(\\(\\d+,\\d+\\))?",
        "javaType" : "java.lang.Double"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "integer",
        "javaType" : "java.lang.Integer"
      }, {
        "matchType" : "REGEX",
        "columnType" : "(tiny|small|medium)*int(\\(\\d+\\))?",
        "javaType" : "java.lang.Integer"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "int4",
        "javaType" : "java.lang.Integer"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "int8",
        "javaType" : "java.lang.Long"
      }, {
        "matchType" : "REGEX",
        "columnType" : "bigint(\\(\\d+\\))?",
        "javaType" : "java.lang.Long"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "date",
        "javaType" : "java.time.LocalDate"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "datetime",
        "javaType" : "java.time.LocalDateTime"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "timestamp",
        "javaType" : "java.time.LocalDateTime"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "time",
        "javaType" : "java.time.LocalTime"
      }, {
        "matchType" : "ORDINARY",
        "columnType" : "boolean",
        "javaType" : "java.lang.Boolean"
      } ]
    }
  },
  "template" : {
    "MybatisPlus" : {
      "name" : "MybatisPlus",
      "elementList" : [ {
        "name" : "controller.java.vm",
        "code" : "##导入宏定义\n$!{define.vm}\n\n##设置表后缀（宏定义）\n#setTableSuffix(\"Controller\")\n\n##保存文件（宏定义）\n#save(\"/controller\", \"Controller.java\")\n\n##包路径（宏定义）\n#setPackageSuffix(\"controller\")\n\n##定义服务名\n#set($serviceName = $!tool.append($!tool.firstLowerCase($!tableInfo.name), \"Service\"))\n\n##定义实体对象名\n#set($entityName = $!tool.firstLowerCase($!tableInfo.name))\n\nimport $!{tableInfo.savePackageName}.service.$!{tableInfo.name}Service;\nimport org.springframework.web.bind.annotation.*;\n\nimport javax.annotation.Resource;\n\n##表注释（宏定义）\n#tableComment(\"表控制层\")\n@RestController\n@RequestMapping(\"$!tool.firstLowerCase($!tableInfo.name)\")\npublic class $!{tableName} {\n    /**\n     * 服务对象\n     */\n    @Resource\n    private $!{tableInfo.name}Service $!{serviceName};\n\n    \n}\n"
      }, {
        "name" : "entity.java.vm",
        "code" : "##导入宏定义\n$!{define.vm}\n\n##保存文件（宏定义）\n#save(\"/entity\", \".java\")\n\n##包路径（宏定义）\n#setPackageSuffix(\"entity\")\n\n##自动导入包（全局变量）\n$!{autoImport.vm}\nimport com.baomidou.mybatisplus.annotation.TableName;\n\nimport java.io.Serializable;\nimport lombok.AllArgsConstructor;\nimport lombok.Data;\nimport lombok.NoArgsConstructor;\nimport lombok.ToString;\n\n##表注释（宏定义）\n#tableComment(\"表实体类\")\n\n@Data\n@ToString\n@NoArgsConstructor\n@AllArgsConstructor\n@TableName(\"$!{tool.hump2Underline($tableInfo.name)}\")\npublic class $!{tableInfo.name} implements Serializable {\n\n    private static final long serialVersionUID = $!tool.serial();\n\n#foreach($column in $tableInfo.pkColumn)\n    #if(${column.comment})\n    /**\n     * ${column.comment}\n     */\n    #end\n    @Schema(description = \"#if(${column.comment})${column.comment}#end\")\n    @TableId(type = IdType.ASSIGN_ID)\n    private $!{tool.getClsNameByFullName($column.type)} $!{column.name};\n#end\n\n\n#foreach($column in $tableInfo.otherColumn)\n\n    #if(${column.comment})\n    /**\n     * ${column.comment}\n     */\n    #end\n    @Schema(description = \"#if(${column.comment})${column.comment}#end\")\n    @TableField(\"#if(${column.name})$!{tool.hump2Underline($column.name)}#end\")\n    private $!{tool.getClsNameByFullName($column.type)} $!{column.name};\n\n#end\n\n## #foreach($column in $tableInfo.fullColumn)\n## #getSetMethod($column)\n## #end\n## \n## #foreach($column in $tableInfo.pkColumn)\n##     /**\n##      * 获取主键值\n##      *\n##      * @return 主键值\n##      */\n##     @Override\n##     protected Serializable pkVal() {\n##         return this.$!column.name;\n##     }\n##     #break\n## #end\n}\n"
      }, {
        "name" : "service.java.vm",
        "code" : "##导入宏定义\n$!{define.vm}\n\n##设置表后缀（宏定义）\n#setTableSuffix(\"Service\")\n\n##保存文件（宏定义）\n#save(\"/service\", \"Service.java\")\n\n##包路径（宏定义）\n#setPackageSuffix(\"service\")\n\nimport com.baomidou.mybatisplus.extension.service.IService;\nimport $!{tableInfo.savePackageName}.entity.$!tableInfo.name;\n\n##表注释（宏定义）\n#tableComment(\"表服务接口\")\npublic interface $!{tableName} extends IService<$!tableInfo.name> {\n\n}\n"
      }, {
        "name" : "serviceImpl.java.vm",
        "code" : "##导入宏定义\n$!{define.vm}\n\n##设置表后缀（宏定义）\n#setTableSuffix(\"ServiceImpl\")\n\n##保存文件（宏定义）\n#save(\"/service/impl\", \"ServiceImpl.java\")\n\n##包路径（宏定义）\n#setPackageSuffix(\"service.impl\")\n\nimport com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;\nimport $!{tableInfo.savePackageName}.mapper.$!{tableInfo.name}Mapper;\nimport $!{tableInfo.savePackageName}.entity.$!{tableInfo.name};\nimport $!{tableInfo.savePackageName}.service.$!{tableInfo.name}Service;\nimport org.springframework.stereotype.Service;\n\n##表注释（宏定义）\n#tableComment(\"表服务实现类\")\n@Service(\"$!tool.firstLowerCase($tableInfo.name)Service\")\npublic class $!{tableName} extends ServiceImpl<$!{tableInfo.name}Mapper, $!{tableInfo.name}> implements $!{tableInfo.name}Service {\n\n}\n"
      }, {
        "name" : "mapper.java.vm",
        "code" : "##导入宏定义\n$!{define.vm}\n\n##设置表后缀（宏定义）\n#setTableSuffix(\"Mapper\")\n\n##保存文件（宏定义）\n#save(\"/mapper\", \"Mapper.java\")\n\n##包路径（宏定义）\n#setPackageSuffix(\"mapper\")\n\nimport com.baomidou.mybatisplus.core.mapper.BaseMapper;\nimport $!{tableInfo.savePackageName}.entity.$!tableInfo.name;\n\nimport org.apache.ibatis.annotations.Mapper;\n\n##表注释（宏定义）\n#tableComment(\"表数据库访问层\")\n@Mapper\npublic interface $!{tableName} extends BaseMapper<$!tableInfo.name> {\n\n}\n"
      } ]
    }
  },
  "columnConfig" : {
    "Default" : {
      "name" : "Default",
      "elementList" : [ {
        "title" : "disable",
        "type" : "BOOLEAN",
        "selectValue" : ""
      }, {
        "title" : "support",
        "type" : "SELECT",
        "selectValue" : "add,edit,query,del,ui"
      } ]
    }
  },
  "globalConfig" : {
    "Default" : {
      "name" : "Default",
      "elementList" : [ {
        "name" : "autoImport.vm",
        "value" : "##自动导入包（仅导入实体属性需要的包，通常用于实体类）\n#foreach($import in $importList)\nimport $!import;\n#end"
      }, {
        "name" : "define.vm",
        "value" : "##（Velocity宏定义）\n\n##定义设置表名后缀的宏定义，调用方式：#setTableSuffix(\"Test\")\n#macro(setTableSuffix $suffix)\n    #set($tableName = $!tool.append($tableInfo.name, $suffix))\n#end\n\n##定义设置包名后缀的宏定义，调用方式：#setPackageSuffix(\"Test\")\n#macro(setPackageSuffix $suffix)\n#if($suffix!=\"\")package #end#if($tableInfo.savePackageName!=\"\")$!{tableInfo.savePackageName}.#{end}$!suffix;\n#end\n\n##定义直接保存路径与文件名简化的宏定义，调用方式：#save(\"/entity\", \".java\")\n#macro(save $path $fileName)\n    $!callback.setSavePath($tool.append($tableInfo.savePath, $path))\n    $!callback.setFileName($tool.append($tableInfo.name, $fileName))\n#end\n\n##定义表注释的宏定义，调用方式：#tableComment(\"注释信息\")\n#macro(tableComment $desc)\n/**\n * $!{tableInfo.comment}($!{tableInfo.name})$desc\n *\n * @author $!author\n * @since $!time.currTime()\n */\n#end\n\n##定义GET，SET方法的宏定义，调用方式：#getSetMethod($column)\n#macro(getSetMethod $column)\n\n    public $!{tool.getClsNameByFullName($column.type)} get$!{tool.firstUpperCase($column.name)}() {\n        return $!{column.name};\n    }\n\n    public void set$!{tool.firstUpperCase($column.name)}($!{tool.getClsNameByFullName($column.type)} $!{column.name}) {\n        this.$!{column.name} = $!{column.name};\n    }\n#end"
      }, {
        "name" : "init.vm",
        "value" : "##初始化区域\n\n##去掉表的t_前缀\n$!tableInfo.setName($tool.getClassName($tableInfo.obj.name.replaceFirst(\"book_\",\"\")))\n\n##参考阿里巴巴开发手册，POJO 类中布尔类型的变量，都不要加 is 前缀，否则部分框架解析会引起序列化错误\n#foreach($column in $tableInfo.fullColumn)\n#if($column.name.startsWith(\"is\") && $column.type.equals(\"java.lang.Boolean\"))\n    $!column.setName($tool.firstLowerCase($column.name.substring(2)))\n#end\n#end\n\n##实现动态排除列\n#set($temp = $tool.newHashSet(\"testCreateTime\", \"otherColumn\"))\n#foreach($item in $temp)\n    #set($newList = $tool.newArrayList())\n    #foreach($column in $tableInfo.fullColumn)\n        #if($column.name!=$item)\n            ##带有反回值的方法调用时使用$tool.call来消除返回值\n            $tool.call($newList.add($column))\n        #end\n    #end\n    ##重新保存\n    $tableInfo.setFullColumn($newList)\n#end\n\n##对importList进行篡改\n#set($temp = $tool.newHashSet())\n#foreach($column in $tableInfo.fullColumn)\n    #if(!$column.type.startsWith(\"java.lang.\"))\n        ##带有反回值的方法调用时使用$tool.call来消除返回值\n        $tool.call($temp.add($column.type))\n    #end\n#end\n##覆盖\n#set($importList = $temp)"
      }, {
        "name" : "mybatisSupport.vm",
        "value" : "##针对Mybatis 进行支持，主要用于生成xml文件\n#foreach($column in $tableInfo.fullColumn)\n    ##储存列类型\n    $tool.call($column.ext.put(\"sqlType\", $tool.getField($column.obj.dataType, \"typeName\")))\n    #if($tool.newHashSet(\"java.lang.String\").contains($column.type))\n        #set($jdbcType=\"VARCHAR\")\n    #elseif($tool.newHashSet(\"java.lang.Boolean\", \"boolean\").contains($column.type))\n        #set($jdbcType=\"BOOLEAN\")\n    #elseif($tool.newHashSet(\"java.lang.Byte\", \"byte\").contains($column.type))\n        #set($jdbcType=\"BYTE\")\n    #elseif($tool.newHashSet(\"java.lang.Integer\", \"int\", \"java.lang.Short\", \"short\").contains($column.type))\n        #set($jdbcType=\"INTEGER\")\n    #elseif($tool.newHashSet(\"java.lang.Long\", \"long\").contains($column.type))\n        #set($jdbcType=\"INTEGER\")\n    #elseif($tool.newHashSet(\"java.lang.Float\", \"float\", \"java.lang.Double\", \"double\").contains($column.type))\n        #set($jdbcType=\"NUMERIC\")\n    #elseif($tool.newHashSet(\"java.util.Date\", \"java.sql.Timestamp\", \"java.time.Instant\", \"java.time.LocalDateTime\", \"java.time.OffsetDateTime\", \"\tjava.time.ZonedDateTime\").contains($column.type))\n        #set($jdbcType=\"TIMESTAMP\")\n    #elseif($tool.newHashSet(\"java.sql.Date\", \"java.time.LocalDate\").contains($column.type))\n        #set($jdbcType=\"TIMESTAMP\")\n    #else\n        ##其他类型\n        #set($jdbcType=\"VARCHAR\")\n    #end\n    $tool.call($column.ext.put(\"jdbcType\", $jdbcType))\n#end\n\n##定义宏，查询所有列\n#macro(allSqlColumn)#foreach($column in $tableInfo.fullColumn)$column.obj.name#if($velocityHasNext), #end#end#end\n"
      } ]
    }
  }
}
```

## 5 使用代码生成器插件

打开 IDEA 右侧 database 工具栏，选中 springboot_demo 数据库中的 student 表。如果没有数据库显示，那么请点集红框所示位置，然后勾选 springboot_demo 数据库即可。

![image-20240722203519891](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-35-20-96e68ab0c05226b4fc4472cc16c0df60-image-20240722203519891-bb4879.png)

选中 student 表之后，右击选择 Generate Code

![image-20240722204314274](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-43-32-e3e71d69951dfe95c21e56bbfe69e0fc-image-20240722204314274-0fdcb4.png)

然后选择 Path

![image-20240722204535433](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-45-36-1d608abbdb5b398b34d3933888c5d770-image-20240722204535433-85a045.png)

然后选择 Package，一定要先选择 Path，再选择 Package

![image-20240722204503892](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-45-04-3e7d63de94829d7c3199e979f209e825-image-20240722204503892-9bbb46.png)

然后选择模板

![image-20240722204642020](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-46-42-40500f58bc389767142ba5b405886b22-image-20240722204642020-92b1ca.png)

然后勾选配置

![image-20240722204700570](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-47-01-ca63d6cd88b8d50e3a4b1532e33588e8-image-20240722204700570-88efc8.png)

然后点击 OK，即可生成代码

生成的结构如下图所示：

![image-20240722205154692](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-52-14-3011500ed1af8ae1ec8710d06fe317f2-image-20240722205154692-04b360.png)

## 6 添加 application.yml 文件

如果 java 目录的同级没有 resources 目录，请手动创建一个，如下图：

![image-20240722205305799](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-53-06-1fa8eb37d61fb2e8b872448bbc1fa0a7-image-20240722205305799-0eb32b.png)

然后在 resources 目录中新建 application.yml 文件，然后添加如下内容

```yml
spring:
  datasource:
    # 如果你的 MySQL 版本是 5.x 请删掉 .cj 这个包，即换成 com.mysql.jdbc.Driver
    driver-class-name: com.mysql.cj.jdbc.Driver
    # 请根据你的实际情况进行更改
    url: jdbc:mysql://localhost:3306/springboot_demo
    username: root
    password: 你的密码
```

## 7 启动项目

打开 SpringbootDemoApplication 类，运行 main 方法即可启动后端服务。

启动成功日志如下：

![image-20240722205755188](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F22%2F20-57-55-df7b9d3a9b5730466058b3ac82dc38eb-image-20240722205755188-37c034.png)

## 8 开始编写接口

打开 controller 包下的 `StudentController.java`。

然后我们来了解一下 Controller 类的基本构成。

```java
package com.xfdzcoder.springbootdemo.controller;


import com.xfdzcoder.springbootdemo.entity.Student;
import com.xfdzcoder.springbootdemo.service.StudentService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 学生信息表(Student)表控制层
 *
 * @author makejava
 * @since 2024-07-22 20:48:33
 */

// @ResponseBody 和 @Controller 注解的组合注解，不懂也没事，反正每个 Controller 上都有
// @ResponseBody：将返回的对象转换成 JSON 格式
// @Controller：标记这个类是 Controller 类
@RestController

// 定义这个 controller 的根路径
@RequestMapping("student")
public class StudentController {
    /**
     * 服务对象
     */
    @Resource
    private StudentService studentService;

}
```

然后还需要知道一些基础知识。

### 8.0 前置知识

#### 8.0.1 HTTP

前端（浏览器）访问 Java后端服务的方式是通过 HTTP 协议来访问的，而 HTTP 协议定义了 8 种请求方法，我们常用的有 4 种，如下：

- GET
  - 查询
- POST
  - 新增
- PUT
  - 修改
- DELETE
  - 删除

可以看到四个 HTTP 方法分别对应了增删改查。那我们怎么标识一个接口的请求方法应该是什么呢？通过下面四个注解

- GetMapping
- PostMapping
- PutMapping
- DeleteMapping

很好记吧，都是 GET、POST、PUT、DELETE

那他们有什么不同呢？

- GET
  - 不能携带对象，所有的参数都拼接在 URL 后面。
  - 所以这种接口的方法参数只能是基本数据类型的包装类和 String。
- POST
  - 可以携带对象，参数可以放在一个叫做请求体的地方，不知道是哪也没关系。
  - 所以这种接口的方法参数可以是一个 Student 对象。
- PUT
  - 可以携带对象，参数可以放在一个叫做请求体的地方，不知道是哪也没关系。
  - 所以这种接口的方法参数可以是一个 Student 对象。
- DELETE
  - 不能携带对象，所有的参数都拼接在 URL 后面。
  - 所以这种接口的方法参数只能是基本数据类型的包装类和 String。

开始编写对 student 表的 CRUD 接口。

#### 8.0.2 MyBatisPlus 之 IService

[持久层接口 | MyBatis-Plus (baomidou.com)](https://baomidou.com/guides/data-interface/#service-interface)

我这里对其进行了稍微的修改，删去了部分不常用的，只需要掌握下面这几个方法即可

>IService](https://gitee.com/baomidou/mybatis-plus/blob/3.0/mybatis-plus-extension/src/main/java/com/baomidou/mybatisplus/extension/service/IService.java) 是 MyBatis-Plus 提供的一个通用 Service 层接口，它封装了常见的 CRUD 操作，包括插入、删除、查询和分页等。通过继承 IService 接口，可以快速实现对数据库的基本操作，同时保持代码的简洁性和可维护性。
>
>IService 接口中的方法命名遵循了一定的规范，如 get 用于查询单行，remove 用于删除，list 用于查询集合，page 用于分页查询，这样可以避免与 Mapper 层的方法混淆。
>
>提示
>
>- 泛型 `T` 为任意实体对象
>- 建议如果存在自定义通用 Service 方法的可能，请创建自己的 `IBaseService` 继承 `Mybatis-Plus` 提供的 `IService` 基类
>- 对象 `Wrapper` 为 [条件构造器](https://baomidou.com/guides/wrapper)
>
># save
>
>```java
>// 插入一条记录（选择字段，策略插入）
>boolean save(T entity);
>```
>
>
>
>**功能描述：** 插入记录，根据实体对象的字段进行策略性插入。
>**返回值：** boolean，表示插入操作是否成功。
>**参数说明：**
>
>| 类型 | 参数名 |   描述   |
>| :--: | :----: | :------: |
>|  T   | entity | 实体对象 |
>
>
>
>**示例（save）：**
>
>```java
>// 假设有一个 User 实体对象
>
>User user = new User();
>
>user.setName("John Doe");
>
>user.setEmail("john.doe@example.com");
>
>boolean result = userService.save(user); // 调用 save 方法
>
>if (result) {
>
>    System.out.println("User saved successfully.");
>
>} else {
>
>    System.out.println("Failed to save user.");
>
>}
>```
>
>生成的 SQL:
>
>```sql
>INSERT INTO user (name, email) VALUES ('John Doe', 'john.doe@example.com')
>```
>
># remove
>
>```java
>// 根据 ID 删除
>boolean removeById(Serializable id);
>```
>
>
>
>**功能描述：** 通过指定条件删除符合条件的记录。
>**返回值：** boolean，表示删除操作是否成功。
>**参数说明：**
>
>|     类型     | 参数名 |  描述   |
>| :----------: | :----: | :-----: |
>| Serializable |   id   | 主键 ID |
>
>**示例（removeById）：**
>
>```java
>// 假设要删除 ID 为 1 的用户
>
>boolean result = userService.removeById(1); // 调用 removeById 方法
>
>if (result) {
>
>    System.out.println("User deleted successfully.");
>
>} else {
>
>    System.out.println("Failed to delete user.");
>
>}
>```
>
>生成的 SQL:
>
>```sql
>DELETE FROM user WHERE id = 1
>```
>
># update
>
>```java
>// 根据 ID 选择修改
>boolean updateById(T entity);
>```
>
>
>
>**功能描述：** 通过指定条件更新符合条件的记录。
>**返回值：** boolean，表示更新操作是否成功。
>**参数说明：**
>
>| 类型 | 参数名 |   描述   |
>| :--: | :----: | :------: |
>|  T   | entity | 实体对象 |
>
>**示例（updateById）：**
>
>```java
>// 假设有一个 User 实体对象，设置更新字段为 email，根据 ID 更新
>
>User updateEntity = new User();
>
>updateEntity.setId(1);
>
>updateEntity.setEmail("updated.email@example.com");
>
>boolean result = userService.updateById(updateEntity); // 调用 updateById 方法
>
>if (result) {
>
>    System.out.println("Record updated successfully.");
>
>} else {
>
>    System.out.println("Failed to update record.");
>
>}
>```
>
>生成的 SQL:
>
>```sql
>UPDATE user SET email = 'updated.email@example.com' WHERE id = 1
>```
>
># get
>
>```java
>// 根据 ID 查询
>T getById(Serializable id);
>```
>
>
>
>**功能描述：** 根据指定条件查询符合条件的记录。
>**返回值：** 查询结果，可能是实体对象、Map 对象或其他类型。
>**参数说明：**
>
>|     类型     | 参数名 |  描述   |
>| :----------: | :----: | :-----: |
>| Serializable |   id   | 主键 ID |
>
>
>
>**示例（getById）：**
>
>```java
>// 假设要查询 ID 为 1 的用户
>
>User user = userService.getById(1); // 调用 getById 方法
>
>if (user != null) {
>
>    System.out.println("User found: " + user);
>
>} else {
>
>    System.out.println("User not found.");
>
>}
>```
>
>生成的 SQL:
>
>```sql
>SELECT * FROM user WHERE id = 1
>```
>
># list
>
>```java
>// 查询所有
>
>List<T> list();
>```
>
>
>
>**功能描述：** 查询符合条件的记录。
>**返回值：** 查询结果，可能是实体对象、Map 对象或其他类型。
>**参数说明：**
>
>| 类型 | 参数名 | 描述 |
>| :--: | :----: | :--: |
>|      |        |      |
>
>
>
>**示例（list）：**
>
>```java
>// 查询所有用户
>
>List<User> users = userService.list(); // 调用 list 方法
>
>for (User user : users) {
>
>    System.out.println("User: " + user);
>
>}
>```
>
>生成的 SQL:
>
>```sql
>SELECT * FROM user
>```
>
># page
>
>```java
>// 无条件分页查询
>
>IPage<T> page(IPage<T> page);
>
>// 条件分页查询
>
>IPage<T> page(IPage<T> page, Wrapper<T> queryWrapper);
>```
>
>
>
>**功能描述：** 分页查询符合条件的记录。
>**返回值：** 分页查询结果，包含记录列表和总记录数。
>**参数说明：**
>
>|    类型    |    参数名    |              描述               |
>| :--------: | :----------: | :-----------------------------: |
>|  IPage<T>  |     page     |            翻页对象             |
>| Wrapper<T> | queryWrapper | 实体对象封装操作类 QueryWrapper |
>
>
>
>**示例（page）：**
>
>```java
>// 假设要进行无条件的分页查询，每页显示10条记录，查询第1页
>
>IPage<User> page = new Page<>(1, 10);
>
>IPage<User> userPage = userService.page(page); // 调用 page 方法
>
>List<User> userList = userPage.getRecords();
>
>long total = userPage.getTotal();
>
>System.out.println("Total users: " + total);
>
>for (User user : userList) {
>
>    System.out.println("User: " + user);
>
>}
>```
>
>生成的 SQL:
>
>```sql
>SELECT * FROM user LIMIT 10 OFFSET 0
>```
>
>**示例（page QueryWrapper 形式）：**
>
>```java
>// 假设有一个 QueryWrapper 对象，设置查询条件为 age > 25，进行有条件的分页查询
>
>IPage<User> page = new Page<>(1, 10);
>
>QueryWrapper<User> queryWrapper = new QueryWrapper<>();
>
>queryWrapper.gt("age", 25);
>
>IPage<User> userPage = userService.page(page, queryWrapper); // 调用 page 方法
>
>List<User> userList = userPage.getRecords();
>
>long total = userPage.getTotal();
>
>System.out.println("Total users (age > 25): " + total);
>
>for (User user : userList) {
>
>    System.out.println("User: " + user);
>
>}
>```
>
>生成的 SQL:
>
>```sql
>SELECT * FROM user WHERE age > 25 LIMIT 10 OFFSET 0
>```

### 8.1 接口示例

```java
    @PostMapping
    public String save(Student student) {
        studentService.save(student);
        return "success";
    }
    
    @PutMapping
    public String update(Student student) {
        studentService.updateById(student);
        return "success";
    }
    

    /*
        这里的 {id} 是一个匹配符，表示匹配一个路径参数。放在这里的含义就是：
            匹配 /student/xxx 的请求，并且 xxx 就是 id
        方法参数中通过 @PathVariable("id") 来将 Long id 这个参数和 url 上的 xxx 进行绑定匹配，springboot 会自动将 xxx 传给这个方法参数
     */
    @DeleteMapping("{id}")
    public String delete(@PathVariable("id") Long id) {
        studentService.removeById(id);
        return "success";
    }
    
    @GetMapping("{id}")
    public Student getById(@PathVariable("id") Long id) {
        return studentService.getById(id);
    }
    
    @GetMapping
    public Page<Student> page(Integer pageNo, Integer pageSize) {
        return studentService.page(Page.of(pageNo, pageSize));
    }
```

## 9 Apifox 的使用

// TODO 明天再写

