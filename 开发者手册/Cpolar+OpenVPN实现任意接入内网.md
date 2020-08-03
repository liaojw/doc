# Cpolar+OpenVPN实现任意接入内网

## 前言

目前来说，我们所在的内网（局域网）有很多，像公司的局域网，工厂的局域网，更为常见的校园网，很多资源的访问需要在内网下可以。 但是当我们在校外，出差等，往往访问那些资源会很不方便，这时候经常会想到VPN技术。 但是像学生是一般不会开放这种权限或资源，需要自己搭建，前提是有一台位于校园网边界的服务器，这个条件更难获取，所以这里我们采用Cpolar+OpenVPN的方式，借助任意一台内网的计算机，实现外网通过VPN接入内网， 进而可以使用内网的各种资源。

## 实现原理图

(图）

![img](https://pic2.zhimg.com/80/v2-b396e30b294c400f44bf23e1d62bb815_1440w.jpg)



**说明：** 1. 利用cpolar将内网的openVPN服务器侦听端口，暴露在公网。 2. 用户通过openVPN的客户端，访问cpolar云平台提供的指定公网TCP端口。 3. cpolar云平台负责转发请求到cpolar客户端。 4. cpolar客户端将请求数据再转发至openVPN服务器，实现内网穿透。 5. 用户登录到内网vpn服务器后，即可像在内网一样访问局域网内的BI服务器。

## Cpolar

### 1. Cpolar简介

cpolar是一个安全的内网穿透工具，通过在公共的端点和本地运行的 Web 服务器之间建立一个安全的信道。cpolar可捕获和分析所有信道上的流量，便于后期分析和重放。

### 2. cpolar的搭建

### 2.1 创建cpolar账号

登录cpolar官网：[www.cpolar.com](https://link.zhihu.com/?target=https%3A//www.cpolar.com/)，注册一个cpolar账号

![img](https://pic2.zhimg.com/80/v2-e5ec3313385b94b352264c2c58cb0f35_1440w.jpg)





### 2.2 添加公网TCP固定端口

### 在cpolar后台仪表盘-->预留-->保留的TCP地址



![img](https://pic2.zhimg.com/80/v2-1360f28a63dc86c98c221c9238134171_1440w.jpg)



> 注：用户需要将套餐升级至专业版以上，才可以保留TCP地址



### 2.2.1 申请一个保留TCP地址

地区选择：**China**, 描述：**openvpn**，点击**保留**按钮。

cpolar云端会分配给您一个固定TCP端口的公网地址: **[http://1.tcp.cpolar.cn:20038](https://link.zhihu.com/?target=http%3A//1.tcp.cpolar.cn%3A20038)**



![img](https://pic1.zhimg.com/80/v2-d71a5b151d2e2f076a5e2c96c89eefc4_1440w.jpg)





### 2.3 cpolar客户端的部署



### 以下服务器端,以CentOS7部署为例



### 切换root用户

```text
su
```

### 更新yum为最新版

```text
yum update -y
```

### 安装必要组件

```text
sudo yum install wget unzip
```

### 下载cpolar客户端

```text
wget https://www.cpolar.com/static/downloads/cpolar-stable-linux-amd64.zip
```

### 解压缩

```text
unzip cpolar-stable-linux-amd64.zip
```



### token认证，登录cpolar后台-->验证，复制token值



![img](https://pic2.zhimg.com/80/v2-14c7269b5b1cf1ed0f58dceb62b65d09_1440w.jpg)





### Token认证

```text
./cpolar authtoken <YzNmYm**************YTZkNjczOGM3>
```

### 移动cpolar到用户path路径

```text
mv ./cpolar /usr/local/bin
```

### 查看版本号

```text
cpolar version
```



![img](https://pic1.zhimg.com/80/v2-46a18833a339f132acae49162c4bdc00_1440w.jpg)



如上图，则显示为正常



### 前台试运行站点测试

```text
cpolar http 8080
```



![img](https://pic4.zhimg.com/80/v2-ffef3d33c7fb289043a0dff8f77f8907_1440w.jpg)



如上图所示，说明启动正常。红框位置显示当前用户名

**参数说明：** http : 穿透协议为http协议 8080 : 本地web站点的8080端口

按ctrl+C退出



### 前台启动固定端口TCP地址

```text
cpolar tcp -remote-addr=1.tcp.cpolar.cn:20038 1194
```

**参数说明：** tcp : 穿透协议为tcp协议 remote-addr : 指定使用预留的某个公网TCP地址,[http://1.tcp.cpolar.cn:20038](https://link.zhihu.com/?target=http%3A//1.tcp.cpolar.cn%3A20038) 为我们上面2.2.1节申请的公网TCP地址 1194 : openVPN服务对外侦听的TCP端口

运行后如图所示

![img](https://pic4.zhimg.com/80/v2-ebd083bdd1910a23faaee67b3427b183_1440w.jpg)



按ctrl+C退出

### 后台运行cpolar固定端口TCP地址

因为之前的运行都是在前台执行，退出ssh终端它就会跟着退出。现在改为后台运行方式

```text
nohup cpolar tcp -remote-addr=1.tcp.cpolar.cn:20038 -log=stdout 1194 &
```

查看后台运行状态

```text
ps -ef | grep cpolar
```



![img](https://pic1.zhimg.com/80/v2-c7e5b879116107481e474dd51f506e7c_1440w.jpg)



现在已经成功将cpolar运动在后台，稍后也可以将cpolar加到开机脚本里，使其可以开机自启动。

## OpenVPN及搭建方式

### 1. OpenVPN的简介

OpenVPN 是一个基于 OpenSSL 库的应用层 VPN 实现。 和传统 VPN 相比，它的优点是简单易用。 [1](https://link.zhihu.com/?target=http%3A//static.zybuluo.com/probezy/v9qvh6904xtpmga3p78w4ael/image_1do1sjmkr6fslquhca1dalet613.png) OpenVPN允许参与建立VPN的单点使用共享密钥，电子证书，或者用户名/密码来进行身份验证。 它大量使用了OpenSSL加密库中的SSLv3/TLSv1协议函式库。 OpenVPN能在Solaris、Linux、OpenBSD、FreeBSD、NetBSD、Mac OS X与Windows2000/XP/Vista上运行，幷包含了许多安全性的功能。 它并不是一个基于Web的VPN软件，也不与IPsec及其他VPN软件包兼容。 [1](https://link.zhihu.com/?target=http%3A//static.zybuluo.com/probezy/v9qvh6904xtpmga3p78w4ael/image_1do1sjmkr6fslquhca1dalet613.png) OpenVPN2.0后引入了用户名/口令组合的身份验证方式，它可以省略客户端证书，但是仍有一份服务器证书需要被用作加密。 OpenVPN所有的通信都基于一个单一的IP端口，默认且推荐使用UDP协议通讯，同时TCP也被支持。 OpenVPN连接能通过大多数的代理服务器，并且能够在NAT的环境中很好地工作。 服务端具有向客户端“推送”某些网络配置信息的功能，这些信息包括：IP地址、路由设置等。 OpenVPN提供了两种虚拟网络接口：通用Tun/Tap驱动，通过它们，可以建立三层IP隧道，或者虚拟二层以太网，后者可以传送任何类型的二层以太网络数据。 传送的数据可通过LZO算法压缩。 在选择协议时候，需要注意2个加密隧道之间的网络状况，如有高延迟或者丢包较多的情况下，请选择TCP协议作为底层协议，UDP协议由于存在无连接和重传机制，导致要隧道上层的协议进行重传，效率非常低下。

## 2. 如何搭建OpenVPN

### 切换root用户

```text
su
```

### 更新yum为最新版

```text
yum update -y
```

### 执行一键安装脚本

```text
wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
```

### 提示绑定在哪个网卡的IP地址，本例中，绑定到192.168.122.1这个内网地址



![img](https://pic4.zhimg.com/80/v2-ee017d4f46bf821e2f6ae33ec3e86db3_1440w.jpg)



### 提示当前服务器在NAT网下，询问公网IP是多少，本例中，输入:192.168.122.1



![img](https://pic1.zhimg.com/80/v2-3d97ab66adba7a947b1e8911e066fa18_1440w.jpg)



### 提示选择协议，选择2，TCP



![img](https://pic2.zhimg.com/80/v2-53f0853a7b8a31e7fdf2707565d05751_1440w.jpg)



### 提示OpenVPN侦听端口，默认为1194



![img](https://pic4.zhimg.com/80/v2-bd20b7f37f57c07241f025470514ef9f_1440w.jpg)



### 提示DNS提供商选择，这里暂时选择3，Google，稍后我们会修改为阿里云的公共DNS



![img](https://pic4.zhimg.com/80/v2-5bef2be74058c20d9ebfc4144ba75637_1440w.jpg)



### 提供一个客户端证书文件的名称，这里默认为client



![img](https://pic1.zhimg.com/80/v2-d256cce59517a7b10837a05adab1a62c_1440w.jpg)



### 按继续，脚本开始批量执行。

### 执行完成后，如下图



![img](https://pic3.zhimg.com/80/v2-e2d5465061ce7478c008e696dc73acc6_1440w.jpg)



生成的结果： 1. 在/root/client.ovpn生成一个客户端证书导入文件，将它从服务器下载到本地。 2. 生成了openvpn-server@server的服务

### 修改openVpn的配置文件

```text
vim /etc/openvpn/server/server.conf
```

修改内容： 1. 在local 192.168.122.1 前面加;注释掉，这样服务会绑定所有网卡上。 2. 将google DNS (8.8.8.8,8.8.4.4),改为阿里共公DNS(223.5.5.5)

修改后如下图

![img](https://pic3.zhimg.com/80/v2-9f6a3bb288bb2d8bd36d1373202bd0ae_1440w.jpg)





### 启动OpenVPN服务

```text
systemctl enable openvpn-server@server
systemctl start openvpn-server@server
```

到此服务端，部署完成。

### OpenVPN 客户端

### 1. 从服务器下载client.ovpn客户端证书文件到本地

如果使用ssh命令行，可以用如下命令行,

```text
scp  root@192.168.2.142:/root/client.ovpn .
```

如果使用其它ssh客户端，请用其它方式下载client.ovpn到本地。



### 2. 下载OpenVPN客户端

Windows: [https://openvpn.net/client-connect-vpn-for-windows/](https://link.zhihu.com/?target=https%3A//openvpn.net/client-connect-vpn-for-windows/) Mac: [https://openvpn.net/client-connect-vpn-for-mac-os/](https://link.zhihu.com/?target=https%3A//openvpn.net/client-connect-vpn-for-mac-os/)



### 2. 修改client.ovpn文件

把remote IP地址改为[http://1.tcp.cpolar.cn](https://link.zhihu.com/?target=http%3A//1.tcp.cpolar.cn) 20038 （我们公网申请的IP和端口号），如下图：

![img](https://pic2.zhimg.com/80/v2-ce55eb41c7c168a892dd735c193beb75_1440w.jpg)



保存

### 3. 安装后导入client.ovpn文件



![img](https://pic4.zhimg.com/80/v2-768b0326705ec1915598b80029bb48b7_1440w.jpg)



### 连接成功



![img](https://pic1.zhimg.com/80/v2-2f5ba1b4be5ff502468cc6ff2b5580c4_1440w.jpg)