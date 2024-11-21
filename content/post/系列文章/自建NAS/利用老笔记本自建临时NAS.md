## 利用老笔记本自建NAS

格式化成ext4

```
(base) root@xfdz-debian:~# mkfs.ext4 /dev/sda
```

挂载

```
(base) root@xfdz-debian:~# mount /dev/sda /mnt/sn570/
```

### 使用NextCloud搭建个人云盘

[Nextcloud - Open source content collaboration platform](https://nextcloud.com/)

https://github.com/nextcloud/all-in-one

首次登录获取密码：

```
cat /var/lib/docker/volumes/nextcloud_aio_mastercontainer/_data/data/configuration.json | grep password
```

