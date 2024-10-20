---
url: /7253629079423852544
title: '私有局域网搭建开发环境其六——GitLab之CI工作流'
date: 2024-10-20T12:52:24+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', '私有局域网搭建开发环境', 'kubernetes']
---

<hr>

## 相关文档

语法说明，常看常新，不会就查：https://docs.gitlab.com/17.4/ee/ci/yaml/index.html

变量的使用，可以让流程更加易于维护：https://docs.gitlab.com/17.4/ee/ci/variables/index.html

## 配置记录

下面记录一下我的简单的一个CI脚本，首先得了解一下目录结构，这个项目是一个多模块的微服务项目，common类的模块为公共类库模块

```yml
.
|-- .flattened-pom.xml
|-- .git
|-- .gitignore
|-- .gitlab-ci.yml
|-- .gitmodules
|-- .idea
|-- .requests
|   |-- generated-requests.http
|   `-- http-client.env.json
|-- .run
|   |-- Template JUnit.run.xml
|   |-- Template Spring Boot.run.xml
|   `-- server
|       |-- debug.sh
|       `-- run.sh
|-- README.md
|-- common
|   |-- .flattened-pom.xml
|   |-- .git
|   |-- .gitignore
|   |-- .gitlab-ci.yml
|   |-- common-cache
|   |   |-- .flattened-pom.xml
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- common-dao
|   |   |-- .flattened-pom.xml
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- common-dependencies
|   |   |-- .flattened-pom.xml
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- common-dubbo
|   |   |-- .flattened-pom.xml
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- common-file
|   |   |-- .flattened-pom.xml
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- common-web
|   |   |-- .flattened-pom.xml
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   `-- pom.xml
|-- conf
|   |-- EasyCodeConfig.json
|   |-- config-dev-server.yml
|   |-- config-dev.yml
|   |-- example
|   |   |-- bootstrap.yml.example
|   |   |-- logback-spring.xml.example
|   |   |-- pom.xml.service.example
|   |   `-- sa-token.yml.example
|   |-- logback-spring.xml
|   |-- sql
|   |   |-- code-sandbox.sql
|   |   |-- community.sql
|   |   |-- database-schema.sql
|   |   |-- manage-user.sql
|   |   |-- question.sql
|   |   |-- user-community.sql
|   |   `-- user.sql
|   `-- temp.bat
|-- docs
|   `-- README.md
|-- logs
|   |-- community
|   |   |-- community.2024-10-04.log
|   |   |-- community.2024-10-05.log
|   |   |-- community.2024-10-10.log
|   |   |-- community.2024-10-12.log
|   |   `-- community.log
|   |-- copilot
|   |   |-- copilot.2024-10-04.log
|   |   `-- copilot.log
|   |-- gateway
|   |   |-- gateway.2024-10-04.log
|   |   |-- gateway.2024-10-05.log
|   |   |-- gateway.2024-10-10.log
|   |   |-- gateway.2024-10-12.log
|   |   `-- gateway.log
|   |-- question
|   |   |-- question.2024-10-04.log
|   |   |-- question.2024-10-05.log
|   |   `-- question.log
|   |-- sandbox
|   |   `-- sandbox.log
|   `-- user
|       |-- user.2024-10-04.log
|       |-- user.2024-10-05.log
|       |-- user.2024-10-12.log
|       `-- user.log
|-- manage
|   |-- .flattened-pom.xml
|   |-- manage-common
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- manage-common-cache
|   |   |-- manage-common-dependencies
|   |   `-- pom.xml
|   |-- manage-community
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- manage-gateway
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- manage-question
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- manage-user
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   `-- pom.xml
|-- mini
|   |-- .flattened-pom.xml
|   |-- mini-common
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- mini-common-api
|   |   |-- mini-common-cache
|   |   |-- mini-common-dependencies
|   |   `-- pom.xml
|   |-- mini-community
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- mini-gateway
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- mini-question
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   |-- mini-user
|   |   |-- .flattened-pom.xml
|   |   |-- .git
|   |   |-- .gitignore
|   |   |-- .gitlab-ci.yml
|   |   |-- Dockerfile
|   |   |-- helm
|   |   |-- pom.xml
|   |   |-- src
|   |   `-- target
|   `-- pom.xml
|-- pom.xml
`-- universal
    |-- .flattened-pom.xml
    |-- pom.xml
    |-- universal-code-sandbox
    |   |-- .flattened-pom.xml
    |   |-- .git
    |   |-- .gitignore
    |   |-- .gitlab-ci.yml
    |   |-- pom.xml
    |   |-- universal-code-sandbox-api
    |   `-- universal-code-sandbox-docker
    `-- universal-copilot
        |-- .flattened-pom.xml
        |-- .git
        |-- .gitignore
        |-- .gitlab-ci.yml
        |-- pom.xml
        |-- universal-copilot-api
        `-- universal-copilot-spark
```

主要文件说明：

- `.flattened-pom.xml` 是 maven 的 flattened 插件生成的用于多模块项目中的版本管理的，详见：[Maven – Maven CI 友好版本](https://maven.apache.org/maven-ci-friendly.html)，这个也应该单独写一篇文章介绍下，这方面没有介绍的比较详细的，大多数都只提 revision 但不提 flattened，（挖个坑
- `.gitlab-ci.yml` 是流水线的配置文件
- `Dockerfile` 是 docker 镜像构建的配置文件，主要相关的就三个

主要模块说明：

- common、manage-common、user-common
  - 分别是整个项目的公共模块、manage的公共模块、user的公共模块
- manage
  - 这下面主要是管理平台的模块，负责CRUD
- user
  - 这下面主要是门户端的模块，负责提供一些个性化查询等功能
- universal
  - 这下面主要是一些公共的服务，负责给其他服务调用的，调用通过Dubbo进行，所以能看到有专门的 api 模块

根据上面几个模块可以划分出三种不同的 CI 配置：

- web服务
- common 类，只需要 install
- universal，两个都要，api模块只需要install，但是也包含了需要运行的web服务

web服务CI配置文件：

```yml
variables:
  PROJECT_NAME: mini-user
  VARIABLES_FILE: variables.txt
  DOCKER_REGISTRY_DOMAIN: 阿里云的容器镜像服务地址/noj/$PROJECT_NAME

stages:
  - package
  - build
  - deploy
#  - clean

package-maven:
  stage: package
  script:
    - whoami
    - pwd
    - export JAVA_HOME=/opt/jdk/jdk21
    - echo JAVA_HOME
    - mvn install -f .flattened-pom.xml -am
  artifacts:
    when: on_success
    expire_in: 20min
    paths:
      - target/*.jar
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'

build-docker:
  stage: build
  image: docker:cli
  before_script:
    - export BUILD_TIME=$(date "+%Y%m%d%H%M%S")
  needs: [package-maven]
  script:
    - echo $BUILD_TIME
    - export TAG=$CI_COMMIT_BRANCH-$BUILD_TIME
    - echo "export TAG=$TAG" > $VARIABLES_FILE
    - docker login -u=$DOCKER_REGISTRY_USERNAME -p $DOCKER_REGISTRY_PASSWORD $DOCKER_REGISTRY_DOMAIN
    - docker build -t $DOCKER_REGISTRY_DOMAIN:$TAG .
    - docker push $DOCKER_REGISTRY_DOMAIN:$TAG
    - echo "build success"
  artifacts:
    paths:
      - $VARIABLES_FILE
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^dev-/'
      when: manual
    - if: '$CI_COMMIT_BRANCH =~ /^develop/'
      when: on_success

deploy-helm:
  stage: deploy
  needs: [build-docker]
  script:
    - source $VARIABLES_FILE
    - export RELEASE=$(echo $CI_COMMIT_BRANCH | sed "s/[^[[:alnum:]]//g")
    - helm upgrade -n noj -i $PROJECT_NAME-$RELEASE ./helm/$PROJECT_NAME
      --set image.tag=$TAG --set nacos.serverAddr=$NACOS_SERVER_ADDR --set nacos.port=$NACOS_PORT
      --set nacos.username=$NACOS_USERNAME --set nacos.password=$NACOS_PASSWORD
      --set nacos.namespace=$NACOS_NAMESPACE --set image.repository=$DOCKER_REGISTRY_DOMAIN
    - echo 'deploy success!'
  artifacts:
    paths:
      - $VARIABLES_FILE
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^dev-/'
      when: manual
    - if: '$CI_COMMIT_BRANCH =~ /^develop/'
      when: on_success
```

common类的 CI：

```yml
stages:
  - package

package-maven:
  stage: package
  script:
    - whoami
    - pwd
    - export JAVA_HOME=/opt/jdk/jdk21
    - echo JAVA_HOME
    - mvn install -f ./common-dao/.flattened-pom.xml -am
    - mvn install -f ./common-dependencies/.flattened-pom.xml -am
    - mvn install -f ./common-web/.flattened-pom.xml -am
    - mvn install -f ./common-cache/.flattened-pom.xml -am
    - mvn install -f ./common-file/.flattened-pom.xml -am
    - mvn install -f ./common-dubbo/.flattened-pom.xml -am
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'
```

universal类的和web服务类差不多，只是多一个打包api模块的步骤

```yml
variables:
  PROJECT_NAME: universal-copilot-spark
  VARIABLES_FILE: variables.txt
  DOCKER_REGISTRY_DOMAIN: xx/noj/$PROJECT_NAME

stages:
  - package
  - build
  - deploy
#  - clean

package-maven:
  stage: package
  script:
    - whoami
    - cd $PROJECT_NAME
    - pwd
    - export JAVA_HOME=/opt/jdk/jdk21
    - echo JAVA_HOME
    - mvn install -f ../universal-copilot-api/.flattened-pom.xml -am
    - mvn install -f .flattened-pom.xml -am
  artifacts:
    when: on_success
    expire_in: 20min
    paths:
      - $PROJECT_NAME/target/*.jar
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'

build-docker:
  stage: build
  image: docker:cli
  before_script:
    - export BUILD_TIME=$(date "+%Y%m%d%H%M%S")
  needs: [package-maven]
  script:
    - echo $BUILD_TIME
    - export TAG=$CI_COMMIT_BRANCH-$BUILD_TIME
    - echo "export TAG=$TAG" > $VARIABLES_FILE
    - cd $PROJECT_NAME
    - docker login -u=$DOCKER_REGISTRY_USERNAME -p $DOCKER_REGISTRY_PASSWORD $DOCKER_REGISTRY_DOMAIN
    - docker build -t $DOCKER_REGISTRY_DOMAIN:$TAG .
    - docker push $DOCKER_REGISTRY_DOMAIN:$TAG
    - echo "build success"
  artifacts:
    paths:
      - $VARIABLES_FILE
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^dev-/'
      when: manual
    - if: '$CI_COMMIT_BRANCH =~ /^develop/'
      when: on_success

deploy-helm:
  stage: deploy
  needs: [build-docker]
  script:
    - source $VARIABLES_FILE
    - export RELEASE=$(echo $CI_COMMIT_BRANCH | sed "s/[^[[:alnum:]]//g")
    - cd $PROJECT_NAME
    - helm upgrade -n noj -i $PROJECT_NAME-$RELEASE ./helm/$PROJECT_NAME
      --set image.tag=$TAG --set nacos.serverAddr=$NACOS_SERVER_ADDR --set nacos.port=$NACOS_PORT
      --set nacos.username=$NACOS_USERNAME --set nacos.password=$NACOS_PASSWORD
      --set nacos.namespace=$NACOS_NAMESPACE --set image.repository=$DOCKER_REGISTRY_DOMAIN
    - echo 'deploy success!'
  artifacts:
    paths:
      - $VARIABLES_FILE
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^dev-/'
      when: manual
    - if: '$CI_COMMIT_BRANCH =~ /^develop/'
      when: on_success
```

## 结语

还是有很多可以改进的地方，不过大致也就这样，另外我的CI都是基于Shell的方式运行的，因为目前就一个电脑Shell是最方便的，如果换成容器的话，需要考虑maven仓库的缓存（自建maven私服）、docker in docker 的实现方式，这过于复杂了，目前初学就先跑通这个流程，升级优化慢慢来。

另外，我用的是 java21，后面也会尝试一下 AOT 打包，毕竟现在确实启动速度确实很慢，内存也占挺多，下面是运行在我一个笔记本上的k8s里的资源消耗情况

![image-20241020132500517](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F10%2F20%2F13-25-15-f7dd6802bc6720e7a165806a27fc10e4-image-20241020132500517-03d6d4.png)

可以看到10个java服务，2个nginx部署的前端，这还是没有任何访问量的情况下，JVM参数还设置了`-server -Xmx250m -Xms100m` 

用 AOT 之后再看吧，好像也不好搞，又挖一个坑















什么？少了Helm？这不就一个包管理器么，感觉跟maven一样，不过xml变成yml了，没啥区别，基本上和k8s的配置一一对应，然后支持 Go 模板语法罢了，这应该没啥好讲的

