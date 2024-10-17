---
url: /7250780131470385152
title: '私有局域网搭建开发环境其五——Kubernetes集群的搭建'
date: 2024-10-12T16:13:18+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'Linux', '私有局域网搭建开发环境', 'kubernetes']
---

<hr>
主节点是我的限制笔记本电脑，之前装Debian那台，但是安装的时候忘记记录了。现在使用其余闲置云服务器安装，并设置为工作节点，记录如下。

## 安装环境：

- `Linux iZhp30asxbevz04dbsdd66Z 3.10.0-957.21.3.el7.x86_64 #1 SMP Tue Jun 18 16:35:19 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux`
- `Docker version 25.0.4, build 1a576c5`

## 参考教程：

- [安装 kubeadm | Kubernetes](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

## 步骤

### 1. 安装容器运行时

这里选择使用Docker作为容器运行时，还需要安装 [cri-dockerd (mirantis.github.io)](https://mirantis.github.io/cri-dockerd/)，原因详见[安装 kubeadm | Kubernetes](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime)

根据自己的系统进行安装即可

#然后安装网络插件，这里选择flannel入门

#`yum install flannel -y`

`systemctl start cri-docker`

### 2. 安装kubelet、kubectl、kubeadm

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl



然后准备 join 到集群中

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/adding-linux-nodes/

使用配置文件的方式定义其他配置：

https://kubernetes.io/zh-cn/docs/reference/config-api/kubeadm-config.v1beta4/#kubeadm-k8s-io-v1beta3-NodeRegistrationOptions

```yaml
apiVersion: kubeadm.k8s.io/v1beta4
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
  #
    apiServerEndpoint: xxxx:6443
    #
    token: 
    #
    caCertHashes: ["sha256:xxx"]
    unsafeSkipCAVerification: true
  #
  tlsBootstrapToken: 
kind: JoinConfiguration
nodeRegistration:
  #
  criSocket: unix:///var/run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  #
  name: wsp.xfdzcoder.org
  #
  taints: []
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
```

然后使用如下命令 join：

```bash
kubeadm join --config join.yaml -v=999
```



### 报错及解决：

#### [WARNING FileExisting-socat]: socat not found in system path

```
yum -y install socat conntrack-tools
```



#### The connection to the server localhost:8080 was refused - did you specify the right host or port?

```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/kubelet.conf $HOME/.kube/config
```

