---
url: /7233392836865990658
title: 'Vite+Vue快速入门'
date: 2024-08-25T16:41:58+08:00
draft: false
summary: "快速入门"
categories: [前端]
tags: ['Vue']
---



## 准备工作：

- 安装 Node，建议使用 `nvm` 安装，安装教程可参考：[多版本管理工具汇总](xfdzcoer.github.io/7233392836865990656)

- WebStorm

## 1. 创建项目

打开 [开始 | Vite 官方中文文档 (vitejs.dev)](https://cn.vitejs.dev/guide/#scaffolding-your-first-vite-project)

执行创建命令：

```shell
npm create vite@latest project-name -- --template vue
```

## 2. 引入组件

### 2.1 ElementPlus

[安装 | Element Plus (element-plus.org)](https://element-plus.org/zh-CN/guide/installation.html)

```shell
npm install element-plus --save
npm install -D unplugin-vue-components unplugin-auto-import unplugin-icons
```

然后配置 vite.conofig.js

```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import Icons from 'unplugin-icons/vite'
import IconsResolver from 'unplugin-icons/resolver'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'
import path from 'node:path'

const pathSrc = path.resolve(__dirname, 'src')

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    AutoImport({
      // Auto import functions from Vue, e.g. ref, reactive, toRef...
      // 自动导入 Vue 相关函数，如：ref, reactive, toRef 等
      imports: [ 'vue' ],

      // Auto import functions from Element Plus, e.g. ElMessage, ElMessageBox... (with style)
      // 自动导入 Element Plus 相关函数，如：ElMessage, ElMessageBox... (带样式)
      resolvers: [
        ElementPlusResolver(),

        // Auto import icon components
        // 自动导入图标组件
        IconsResolver({
          prefix: 'Icon'
        })
      ],

      dts: path.resolve(pathSrc, 'auto-imports.d.ts')
    }),

    Components({
      resolvers: [
        // Auto register icon components
        // 自动注册图标组件
        IconsResolver({
          enabledCollections: [ 'ep' ]
        }),
        // Auto register Element Plus components
        // 自动导入 Element Plus 组件
        ElementPlusResolver()
      ],

      dts: path.resolve(pathSrc, 'components.d.ts')
    }),

    Icons({
      autoInstall: true
    })
  ],
  resolve: {
    alias: {
      '@': pathSrc
    }
  }
})

```

### 2.2 Pinia

[开始 | Pinia (vuejs.org)](https://pinia.vuejs.org/zh/getting-started.html)

```shell
npm install pinia
```

然后配置 main.js

```javascript
// Pinia
import { createPinia } from 'pinia'
const pinia = createPinia()
app.use(pinia)
```

### 2.3 Router

[安装 | Vue Router (vuejs.org)](https://router.vuejs.org/zh/installation.html)

```shell
npm install vue-router@4
```

在 `src` 下创建 `router/index.js` 文件

内容如下，先创建一个空的路由即可

```js
import { createMemoryHistory, createRouter } from 'vue-router'


const routes = [

]

const router = createRouter({
  history: createMemoryHistory(),
  routes,
})

export default router
```

然后配置 main.js

```js
// Router
import router from '@/router/index.js'
app.use(router)
```

配置 pinia 插件：[快速开始 | pinia-plugin-persistedstate (prazdevs.github.io)](https://prazdevs.github.io/pinia-plugin-persistedstate/zh/guide/)

```shell
npm i pinia-plugin-persistedstate
```

main.js 配置

```js
// Pinia
import { createPinia } from 'pinia'
const pinia = createPinia()
// Pinia Plugins
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'
pinia.use(piniaPluginPersistedstate)
app.use(pinia)
```

### 2.4 Axios

[起步 | Axios中文文档 | Axios中文网 (axios-http.cn)](https://www.axios-http.cn/docs/intro)

```shell
npm install axios
```

在 `src` 下创建 `utils/request.js` 进行请求工具封装，记得在请求响应拦截器中根据项目情况添加配置

```js
import axios from 'axios'

const instance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 1000
})

// 添加请求拦截器
instance.interceptors.request.use(
  config => {
    // 修改请求之前的配置
    return config
  },
  error => {
    // 请求错误的处理逻辑
    return Promise.reject(error)
  }
)

// 添加响应拦截器
instance.interceptors.response.use(
  response => {
    // 统一处理响应数据
    return response.data
  },
  error => {
    // 统一处理响应错误
    return Promise.reject(error)
  }
)

export default instance
```

然后配置 env 环境变量，因为上面用到了 `VITE_API_BASE_URL`

[环境变量和模式 | Vite 官方中文文档 (vitejs.dev)](https://cn.vitejs.dev/guide/env-and-mode.html)

在 项目根目录 下新建 `.env.development`  文件

```properties
VITE_API_bASE_URL = localhost:8080
```

