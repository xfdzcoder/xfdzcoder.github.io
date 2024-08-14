---
url: /7228614255380045824
title: 'NOJ——AI智能判题系统'
date: 2024-08-09T11:11:35+08:00
draft: false
summary: "AI助力传统OJ走上智能化转型的新道路，在新的道路上持续不断的挖掘新质生产力"
categories: [Java]
tags: ['top', '毕业设计']
---

<hr>

## 简历部分

主要技术：SpringCloud + Spring AI
项目描述：NOJ——New OJ 智能判题系统。通过引入AI 大语言模型来弥补传统 OJ 的短板，在传统 OJ 系统的基础上引入 AI 答疑、AI 判题、AI 代码纠错 等功能。
主要职责： 

- 使用**黑白名单 + SecurityManager** 来限制被运行代码的网络、文件等权限、Docker 容器来将被运行代码与物理主机隔离，确保了**代码沙箱的安全性**。
- 为解决 ElasticSearch 和 MySQL 的数据同步问题，系统引入了 RocketMQ 来作为消息队列，对搜索和管理服务进行**解耦**。
- 为解决传统 OJ 系统无法评判主观题的短板，系统引入了业界成熟的 **AI 模型**来对主观题进行**评分**，减少了不必要的人工成本。
- 通过对接成熟 AI 大语言模型为用户提供 **AI 答疑**等功能，帮助用户理解和探索知识。
- 为支持多语言判题，使用**模板方法设计模式**规范代码执行流程，并提供上层接口供外部服务调用，同时支持使用 **SPI 机制**、**Spring 依赖注入**等方式来自定义扩展语言支持。

## 需求分析

### 用户需求

- 传统 OJ 题目水平参差不齐，学生遇到错题无法及时解决，主观题完全依靠老师手动判分。在 AI 大语言模型的浪潮中，这些都将被优化升级。
- AI 可以对题目进行预处理，防止明显的逻辑和文字等低级错误。
- 学生遇到难题可以通过与 AI 互动答疑，减轻老师压力。
- AI 可以对主观题进行预评分，并预留反馈渠道，学生可对评分发起疑问，然后再由人工评判。

### 功能需求

#### 代码沙箱

- 多语言支持
- 安全性支持
- 内存、时间等资源消耗查看
- 多模式支持
  - 核心方法模式：类似Leetcode 只需要实现特定方法即可。
  - ACM模式：用户需要自行处理输入输出。

#### AI 辅助

- 多 AI 平台支持
- AI 判题
- AI 答疑
- AI 代码纠错

#### 题库

- 搜索
- Excel导入导出
- 随机答题模式
- 顺序背题模式
- 积分规则
- 会员规则

#### 用户

- 动态多角色支持
- 管理题库
- 管理下级角色
- 积分管理

#### 板块

- 帖子
- 评论
- 标签

### 实体和值对象

#### 代码沙箱

##### 实体

- CodeInfo：代码对象
  - String code：代码字符串
  - Long size：代码文件大小，单位字节
  - LanguageTypeEnum languageType：语言类型枚举
  - QuestionInfo questionInfo：题目信息
  - Result result：运行结果信息

##### 值对象

- LanguageTypeEnum languageType：语言类型枚举（通用）
  - String name：编程语言标准名称
  - String version：版本号
- QuestionInfo：题目信息
  - Long questionInfoId：题目信息 id
  - CodeTypeEnum type：ACM / 核心方法 模式
  - Integer timeout：时间限制，单位毫秒
  - Integer memory：内存限制，单位 MB
  - String testCaseUrl：测试用例位置
- Result result：运行结果信息
  - Boolean：运行结果是否正确
  - Integer realTimeout：真实耗时，单位毫秒
  - Integer realMemory：真实使用内存，单位 MB
  - Integer passedCase：通过测试用例的数量
  - Integer totalCase：测试用例总数
  - String input：标准输入，仅在解答错误时才有，值为解答失败的测试用例的输入
  - String output：标准输出，仅在解答错误时才有，值为解答失败的测试用例的输出
  - String exceptOutput：期望输出，仅在解答错误时才有，值为解答失败的测试用例的期望输出
  - String throwableOutput：错误或异常输出
  - ExitEnum exitType：退出类型，如正常退出、超时、内存超限、编译错误、运行错误、越权等

##### 命令

- Result：运行结果信息
  - static Result parse(String json)：解析 json 字符串构造对象

##### 领域服务

- ICodeInfo
  - CodeInfo execute(CodeInfo codeInfo)：执行代码
- CommandBuilderStrategy
  - boolean support(String language)：判断当前策略是否支持该语言
  - String buildCommand(QuestionInfo param)：构造执行命令行
- CommandBuilderFactory
  - createStrategy(String language)：根据语言选择策略，通过 SPI 或 Spring 依赖注入 进行选择。

#### AI 辅助

##### 实体

- AiMessage：AI 消息
  - String sessionId：会话 ID
  - Long timestamp：时间戳
  - String message：消息内容
  - MessageTypeEnum messageType：消息类型枚举
  - RoleEnum role：角色类型，AI 或 用户
  - ModelTypeEnum modelType：AI 模型类型

##### 值对象

- MessageTypeEnum
  - String type：类型，文本、图片等
  - String name：名称
- RoleEnum
  - String code：角色唯一code
  - String name：名称
- ModelTypeEnum
  - String type：类型，是完整名称：如 GPT-3.5 等

##### 命令

##### 领域服务

- IAiMessage
  - AiMessage generate(String message)

#### 题库

##### 实体

- QuestionBank：题库（聚合根）
  - String name：名称
  - String identifier：编号
  - String coverImage：封面图
  - Long plateId：所属板块 ID
  - Integer studyCount：学习人数
  - Integer goodRate：好评率
  - String description：描述
  - Integer questionCount：题目数量
  - Boolean needVip：是否是会员题库
  - Integer score：购买所需积分
  - List\<TemplateCode>：模板代码
  - List\<QuestionInfo> questions：题目
- QuestionInfo：题目
  - String name：名称
  - String identifier：编号
  - Integer answerCount：题解数量
  - Integer commitCount：提交次数
  - Integer passCount：通过次数
  - Integer passRate：通过率
  - Integer collectCount：收藏量
  - Integer discussionCount：评论量
  - DifficultyEnum difficulty：难度
  - String[] tags：标签，用英文逗号分隔
  - String description：题目描述，markdown格式
  - String testCaseUrl：对应测试用例位置
  - Long creatorId：贡献者
  - Long bankId：所属题库 id
  - List\<Discussion> discussionList：评论列表，只包含顶层评论。
- Discussion：讨论
  - Long questionInfoId：所属题目 ID
  - Long parentId：回复的评论 ID，当没有父评论时为NULL
  - String content：内容
  - Long userId：发表评论的用户
  - Integer goodCount：点赞量
  - Integer status：状态，0为已发布，1为已删除
  - Integer childDiscussionCount：子评论数量
  - List\<Discussion> children：子评论

##### 值对象

- TemplateCode：模板代码
  - LanguageTypeEnum languageType：语言类型枚举
  - String code：模板代码
- DifficultyEnum 难度
  - String type：难度类型，简单 / 中等 / 困难

##### 命令

- QuestionBank
  - static QuestionBank import(MutipartFile file)：从excel文件导入
  - static MutipartFile export(QuestionBank questionBank)：从对象导出 



