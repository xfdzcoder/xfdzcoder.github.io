---
url: /7224246078978457602
title: '红黑树'
date: 2022-07-26T14:13:04+08:00
draft: false
summary: "B+树的学习"
categories: [数据结构与算法]
tags: ['树']
---



## 0. 预备知识

- **AVL 树**
- **2-3-4 树**
## 1. 前言
红黑树（Red Black Tree） 是一种自平衡二叉查找树。红黑树是在1972年由[Rudolf Bayer](https://baike.baidu.com/item/Rudolf%20Bayer/3014716?fromModule=lemma_inlink)发明的，当时被称为平衡二叉B树（symmetric binary B-trees）。后来，在1978年被 Leo J. Guibas 和 Robert Sedgewick 修改为如今的“红黑树”。<br />红黑树是一种平衡二叉查找树的变体，它的左右子树高差有可能大于 1，所以红黑树不是严格意义上的[平衡二叉树](https://baike.baidu.com/item/%E5%B9%B3%E8%A1%A1%E4%BA%8C%E5%8F%89%E6%A0%91/10421057?fromModule=lemma_inlink)（AVL），但 对之进行平衡的代价较低， 其平均统计性能要强于 AVL 。
> 作者说：正是因为 AVL 树的平衡条件过于严格，导致频繁修改数据时会导致大量的旋转操作，从而影响性能。而红黑树利用改变结点颜色达到了减少了旋转操作次数，所以其平均统计性能要强于 AVL。

## 2. 红黑树特征

1. 结点是红色或黑色。
2. 根结点是黑色。
3. 所有叶子都是黑色。（叶子是NIL结点）
4. 每个红色结点的两个子结点都是黑色。（从每个叶子到根的所有路径上不能有两个连续的红色结点）
5. 从任一结点到其每个叶子的所有路径都包含相同数目的黑色结点。

**关于特征原理解释，详见：**[1-红黑树前置知识-二叉排序树常见操作详解_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV135411h7wJ?p=1)<br />由上视频可知，一颗红黑树对应着唯一一颗 2-3-4树，一颗 2-3-4树对应多颗红黑树。两者结点转换关系如下：<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958504848-ea3a5640-eece-49fb-9d7b-e97a5c916a96.png#averageHue=%23f3eeed&clientId=ub8aaa0ed-567a-4&from=paste&height=377&id=u6d32506c&originHeight=377&originWidth=988&originalType=binary&ratio=1&rotation=0&showTitle=false&size=37424&status=done&style=none&taskId=uc28ad20c-8b00-4b1b-9315-2fb585fd802&title=&width=988)
## 3. 插入（结合 2-3-4 Tree 进行理解）
这里我们通过顺序插入** {50, 60, 70, 80, 90, 100} **来进行理解<br />下图都按照以下结构：<br />![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958209783-20921756-09a4-434d-8d20-e1879d37f1e0.png#averageHue=%23f2f1f0&clientId=ub8aaa0ed-567a-4&from=paste&height=114&id=u8bf60580&originHeight=114&originWidth=1273&originalType=binary&ratio=1&rotation=0&showTitle=false&size=21366&status=done&style=none&taskId=u38bc2c1b-7318-4157-a8f6-bdc870e6da6&title=&width=1273)
### 3.1 插入 50
![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958227237-d6986bbe-32c6-425b-9932-53fe09a56be4.png#averageHue=%23eeeeee&clientId=ub8aaa0ed-567a-4&from=paste&height=143&id=ue2be7aed&originHeight=143&originWidth=1119&originalType=binary&ratio=1&rotation=0&showTitle=false&size=9345&status=done&style=none&taskId=u772ba5af-b3ab-49e6-8486-88c15c000cd&title=&width=1119)
### 3.2 插入 60
![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958237851-d0f16621-a38b-4614-891b-7956f983d3bb.png#averageHue=%23f2ecec&clientId=ub8aaa0ed-567a-4&from=paste&height=229&id=u00eb899a&originHeight=229&originWidth=1217&originalType=binary&ratio=1&rotation=0&showTitle=false&size=20107&status=done&style=none&taskId=u992c2d1c-ff44-4364-9d7c-9cde9113c53&title=&width=1217)
### 3.3 插入 70
![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958255631-03eb4843-a8fa-45e9-9cec-ca98baf3677d.png#averageHue=%23f4ebeb&clientId=ub8aaa0ed-567a-4&from=paste&height=301&id=ucafb91ce&originHeight=301&originWidth=1320&originalType=binary&ratio=1&rotation=0&showTitle=false&size=27052&status=done&style=none&taskId=u87337b4f-6660-4da8-b1f4-45a3d424bdc&title=&width=1320)<br />此时插入70后需要左旋。
### 3.4 插入 80
![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958558040-d95a7b0b-a1c2-41d7-b1b8-fe047563f3c1.png#averageHue=%23f0e7e7&clientId=ub8aaa0ed-567a-4&from=paste&height=330&id=u77320e2c&originHeight=330&originWidth=1379&originalType=binary&ratio=1&rotation=0&showTitle=false&size=33432&status=done&style=none&taskId=u439384ea-5bcb-4d4a-b0df-6417ac3692a&title=&width=1379)<br />此时直接改变颜色即可
### 3.5 插入 90
![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958596172-6229b328-4840-47b3-8fe1-c11e53436151.png#averageHue=%23ede5e5&clientId=ub8aaa0ed-567a-4&from=paste&height=361&id=ue681dd9e&originHeight=361&originWidth=1437&originalType=binary&ratio=1&rotation=0&showTitle=false&size=37596&status=done&style=none&taskId=u648331b1-eadc-4ad1-81d2-4ff700ecd10&title=&width=1437)<br />需要左旋
### 3.6 插入 100
![image.png](https://cdn.nlark.com/yuque/0/2023/png/34254608/1674958627474-356ef75b-5bfd-416d-b4f9-bcbe12f1f021.png#averageHue=%23ebe3e3&clientId=ub8aaa0ed-567a-4&from=paste&height=379&id=ub1359094&originHeight=379&originWidth=1503&originalType=binary&ratio=1&rotation=0&showTitle=false&size=52373&status=done&style=none&taskId=uc5933afb-8d2c-4187-bd5d-00e9f14fa8a&title=&width=1503)<br />此时，若使用 AVL 树存储数据，那么就要进行一次左旋，而红黑树利用改变结点颜色避免了一次左旋，树也差不多是平衡的。
### 结论
观察上述插入过程，可以发现：
#### 插入过程

1. 插入的结点始终是红色（根节点除外）
2. 若父结点的兄弟结点存在，则改变颜色即可，无需旋转
   1. 例如插入 80、100 时
3. 若父结点的兄弟结点不存在，则需要根据树的偏移情况进行旋转，旋转完成之后再修改颜色
   1. 例如插入 70、90 时
#### 颜色改变
分两种情况：
> 旋转通常只涉及三结点，在 AVL 中，我们会在三结点的上结点发现树不平衡，需要旋转，而在红黑树中，我们会在三结点的中结点发现需要旋转。所以下面两点中的 当前节点 指的是旋转三结点的中结点

1. 旋转后改变颜色
   1. 三结点通过 L、R、LR、RL 旋转完成之后都是 一上二下式，所以旋转完成之后修改父结点为黑色，下方两个子结点为 红色即可。
2. 不旋转，直接改变颜色
   1. 这种情况是父结点有兄弟结点，则直接将父结点设为红色（注意父结点是根节点的情况），当前结点和兄弟结点设为黑色即可。

## 4. 删除
