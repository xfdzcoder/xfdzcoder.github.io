---
url: /7224237482966319106
title: 'HashSet 源码分析'
date: 2022-01-17T22:46:45+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Java基础']
---

# P521-P525 跟着老韩读源码

感谢韩顺平老师！

下面是视频地址

[【零基础 快速学Java】韩顺平 零基础30天学会Java_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1fh411y7R8?p=522)

**干就完了！**

以防忘记，写下来了一些笔记（其实大都是抄韩老师写的）

## 总结：

- HashSet 底层是 HashMap
- **添加机制**

1. 添加一个元素时，先得到Hash值，Hash值会转成 -> 索引值
2. 找到存储数据表 table ，看这个位置是否已经存放元素
3. 如果没有，则直接加入
4. 如果有，调用 equals（该方法可重写，具体比较逻辑可由开发者定制） 比较，如果相同，就放弃添加，如果不同，则添加到最后
5. 在Java8中，如果一条链表的元素个数 >= TREEIFY_THRESHOLD (默认是8) ，并且 table 的大小 >= MIN_TREEIFY_CAPACITY(默认64)，就会进行树化（红黑树）
    - 如果当链表长度 > 8，但是 table 的大小还未 >= 64，那么会将 table 扩容（双倍扩容）

- **扩容机制**
    1. 第一次添加元素直接扩容到 16 ， 阈值为 16 * 0.75 == 12
    2. 当 table 长度到达 12 时就会准备扩容，**第13个元素成功**添加后就会扩容（双倍扩容），即扩容到 32。此时的阈值为 24
        - 第13个元素是指：**数组加链表的总元素个数**，而不是单指在数组上的元素个数或者在链表上的元素个数
    3. 以此类推...
- Java设计者买菜是不是也用补码算钱的，太强了啊！！！





## 源码解读：

### 示例代码：

```java
public static void main(String[] args) {

        HashSet set = new HashSet();

        set.add("java");
        set.add("PHP");
        set.add("java");

        System.out.println("set = " + set);


    }
```

### line 3 ：

![image-20220117152954696](https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_15-30-01.png)

HashSet的无参构造**创建HashMap对象**,默认长度是0 {}

![image-20220117153418020](https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_15-34-18.png)

并将 DEFAULT_LOAD_FACTOR （默认负载系数）赋值给 loadFactor

### line 5 ：

![image-20220117153607086](https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_15-36-07.png)

![image-20220117154758123](https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_15-47-58.png)

调用HashMap 对象 map 的public V put(K key, V value)方法；**PRESENT只是填补value这个位置**，传入参数key可变化，但value一直是PRESENT(官方文档：要与后备映射中的对象关联的虚拟值)

![image-20220117153748333](https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_15-37-48.png)

再次调用 static final int hash(Object key) 方法，得到 key 的 hash值

![image-20220117155349948](https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_15-53-49.png)

在 hash() 里判断传入参数key是否为空，若为空则返回0，若不为空则根据 (h = key.hashCode()) ^ (h >>> 16) 算法（为避免碰撞）计算其 hash 值（不完全等价于HashCode）并返回，作为putVal() 方法的第一个参数

#### putVal(...)

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
    // 定义辅助变量
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // table 是放 Node 结点的数组，类型是 Node[]
    // if语句表示 如果当前的 table 是 null，或者大小 == 0，则进行第一次扩容
    if ((tab = table) == null || (n = tab.length) == 0)
        // resize()：第一次扩容table数组
        n = (tab = resize()).length;
    // 根据 key 得到的 Hash 值去计算 key 应该存放到 table 表的哪个索引位置
    // 并把这个位置的对象，赋给 p
    // 再判断 p 是否为 null
    //     如果 p 为空：表示还未存放元素，就创建一个Node（hash 用于比较是否相等，key 是传入参数，value 是 PREENT ，null 类似于 尾结点
    //     如果 p 不为空：line 18 ：即 key 元素本应存放的位置已经存放了元素，被占用了，所以table[...]不为空
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        ...
    }
    ++modCount;
    // threshold == 12 
    // 判断长度是否大于 12 ，是否进行扩容
    if (++size > threshold)
        resize();
    // hashMap留给其子类的方法，此方法在HashMap中为空
    afterNodeInsertion(evict);
    return null;
}
```

##### line 9 ：resize()

```java
final Node<K,V>[] resize() {
    // table == 0
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    if (oldCap > 0) {
        ...
    // initial capacity was placed in threshold
    else if (oldThr > 0) 
        newCap = oldThr;
    // zero initial threshold signifies using defaults
    else {
        // 扩容长度 ： 16（DEFAULT_INITIAL_CAPACITY == 1 << 4 == 16
        newCap = DEFAULT_INITIAL_CAPACITY;
        // 确定阈值：当table长度到达 16 * DEFAULT_LOAD_FACTOR（0.75） == 12的时候就准备扩容，防止当操作量比较大时发生阻塞
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    @SuppressWarnings({"rawtypes","unchecked"})
    // 创建一个长度为 newCap（16） 的Node[]
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    // 并赋值给 table ，所以table的长度也是16
    table = newTab;
    if (oldTab != null) {
        ...
    }
    return newTab;
}
```

##### line 18 ：... : 

```java
// 开发技巧提示：局部变量在需要时再创建
// 定义辅助变量
Node<K,V> e; K k;
// 将准备添加的 key 的 hash值 与 p(是当前索引位置的链表的第一个元素) 的 hash值比较
if (p.hash == hash &&
    // 并且满足 准备加入的 key 与 p 指向的 Node 结点的 key 是同一个对象
    //         或者 两者不是同一个对象，但两者 通过p 指向的 Node 结点的 key 的equals()比较后 相同
    //                                                         此equals()程序员可以定制
    ((k = p.key) == key || (key != null && key.equals(k))))
    e = p;
// 判断 p 是不是一颗红黑树
// 如果是 红黑树 ，就调用putTreeVal()方法添加
else if (p instanceof TreeNode)
    e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
// 
else {
    // 依次和该链表的每一个元素比较后，都不相同，则添加到该链表的最后
    for (int binCount = 0; ; ++binCount) {
        // 由于前面已经比较了一次，这里不在比较
        // 判断是否到了链表的最后（链表最后一个结点的next是null）
        // 并且将结点 p 的尾结点 p.next 赋值给 e
        // 由于这里比较的是尾结点是否为空，故当链表长度为9时才能使 binCount 为 7 （binCount 是从 0 开始，为 7 时循环 8 c）
        if ((e = p.next) == null) {
            // 已经到了链表末尾，用传入参数 key 创建一个 Node 结点添加到最后一个结点 p 的末尾，即添加到 p.next
            p.next = newNode(hash, key, value, null);
            // 添加元素到链表后，立即判断该链表是否已经达到 8 个结点
            // 如果达到，就调用 treeifyBin() 对当前链表进行树化（转成红黑树）
            // ！！！注意：在转成 红黑树 时，要进行判断，详见下方 treeifyBin(tab, hash)
            if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                treeifyBin(tab, hash);
            break;
        }
        // 
        // 没有到末尾，则比较 传入参数 key 与 当前索引位置的第一个元素的下一个元素（因为前面 e = p.next） 比较是否相等
        // 比较逻辑同前文一样
        if (e.hash == hash &&
            ((k = e.key) == key || (key != null && key.equals(k))))
            break;
        p = e;
    }
}
if (e != null) { // existing mapping for key
    V oldValue = e.value;
    if (!onlyIfAbsent || oldValue == null)
        e.value = value;
    afterNodeAccess(e);
    return oldValue;
}
```

###### line ： 29 ：treeifyBin(tab, hash)：

```java
// 当链表的长度大于等于 8 时，进入此方法
final void treeifyBin(Node<K,V>[] tab, int hash) {
    int n, index; Node<K,V> e;
    // 若 tab的长度还未到达 MIN_TREEIFY_CAPACITY(64) ，则先进行扩容，暂时不树化
    if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY)
        resize();
    else if ((e = tab[index = (n - 1) & hash]) != null) {
        TreeNode<K,V> hd = null, tl = null;
        do {
            TreeNode<K,V> p = replacementTreeNode(e, null);
            if (tl == null)
                hd = p;
            else {
                p.prev = tl;
                tl.next = p;
            }
            tl = p;
        } while ((e = e.next) != null);
        if ((tab[index] = hd) != null)
            hd.treeify(tab);
    }
}
```

## 课后疑问：

为什么在链表长 >= 8时，原本在table[4]位置的链表被移到了 table[36]？

### 问题分析：

当链表长度 >= 8 且 table 长度 < 64 时，会在 **resize() 方法** 即本文 **line ： 29 ：treeifyBin(tab, hash)：**代码块中的 line ：6 处进入 **resize() 方法**并进行扩容，此处将 **resize() 方法** 的代码补全，并加以分析

### resize() 方法源码分析：

此时：

<img src="https://gitee.com/Lx_Vae/image/raw/master/imge/2022-01-17_21-07-48.png" alt="image-20220117210748799" style="zoom:200%;" />

且只在 table[4] 位置存在一个长度为 10 的链表

链表长度为 9 时第一次扩容 table.length 16 --> 32

链表长度为 10 时第二次扩容 table.length 32 --> 64

```java
final Node<K,V>[] resize() {
    // 将 table 备份
	Node<K,V>[] oldTab = table;
    // 判断是不是第一次扩容
    //     第一次扩容：上一个table的长度为 0
    //     否则：得到上一个 table 的实际长度（包括null）
	int oldCap = (oldTab == null) ? 0 : oldTab.length;
    // 备份threshold
	int oldThr = threshold;
    // 定义辅助变量
	int newCap, newThr = 0;
    
	if (oldCap > 0) {
        // 判断 table 长度是否超过 2的30次方，暂不探究
		if (oldCap >= MAXIMUM_CAPACITY) {
			threshold = Integer.MAX_VALUE;
			return oldTab;
		}
    	// 将旧的 table 长度 左移一位：即乘以 2 ，再赋值给 新的 table 长度即 newCap
		else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
			oldCap >= DEFAULT_INITIAL_CAPACITY)
            // 将 旧的阈值也 乘以 2
			newThr = oldThr << 1; // double threshold
	}
    /*
    // 这一段源码在本次操作中并不会涉及，故注释一下
    // initial capacity was placed in threshold
	else if (oldThr > 0) 
		newCap = oldThr;
    // zero initial threshold signifies using defaults
	else {               
		newCap = DEFAULT_INITIAL_CAPACITY;
		newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
	}
	if (newThr == 0) {
		float ft = (float)newCap * loadFactor;
		newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
		(int)ft : Integer.MAX_VALUE);
	}
	*/
    // 将 翻倍后的 阈值 赋值给此对象的 threshold
    threshold = newThr;
	@SuppressWarnings({"rawtypes","unchecked"})
    // 定义一个 长度为 newCap（即翻倍后的 oldCap）的 Node 数组
    // 来储存原 Node 数组内的元素
	Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    // 将原Node[] 即 table 覆盖，或者说 使 table 指向新的Node[]
	table = newTab;
	if (oldTab != null) {
        // 循环遍历 原Node[] 中的每一个元素
		for (int j = 0; j < oldCap; ++j) {
            // 定义辅助变量，储存从原 Node[] 取出的 Node对象
			Node<K,V> e;
            // 将原 Node[] 中的第 j 个元素赋值给 e，相当于备份
            // 并判断其是否为空，此时：第四个元素不为空，其余都为空
			if ((e = oldTab[j]) != null) {
                // 将原来存有元素的位置用null替换
				oldTab[j] = null;
                // 判断该位置是否形成链表
				if (e.next == null)
                    // 没有形成链表，则直接将备份的 e 以相同的方式计算出其在 Node[] 中的位置后赋值到该位置
					newTab[e.hash & (newCap - 1)] = e;
                // 已经形成链表，判断是否为红黑树，此时未树化
                // 暂时未学习数据结构，暂不探究
				else if (e instanceof TreeNode)
					((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                // 进入到这
				else { // preserve order
                    // 定义辅助变量
					Node<K,V> loHead = null, loTail = null;
					Node<K,V> hiHead = null, hiTail = null;
					Node<K,V> next;
                    // 将此链表上的元素通过 do...while(...) 循环放到一个新的链表上 
					do {
                        next = e.next;
                        // 关于这里的按位与，会在下面放一段链接，看完就懂
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                            }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    // 如果前面按位与的结果是 0，则将复制的链表放回原位置
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    // 如果前面按位与的结果不为 0，则将复制的链表放到 j + oldCap 处
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

line 77：[【转】Java8 resize() 机制_AJ1101的博客-CSDN博客_java resize](https://blog.csdn.net/AJ1101/article/details/80301522)

