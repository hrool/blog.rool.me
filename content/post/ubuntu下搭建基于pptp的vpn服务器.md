+++
date = "2014-01-14T20:19:05+08:00"
title = "ubuntu下搭建基于pptp的vpn服务器"
categories = [ "技术" ]
tags = [ "ubuntu","pptp","vpn" ]
+++


为了翻墙，在亚马逊的vps上搭建基于pptp的vpn服务器。系统环境：ubuntu12.04
##  安装pptp:
```bash
apt-get update
apt-get -y install pptpd
```
<!--more-->

## 设置pptp使用的ip和dns:
`vim /etc/pptpd.conf`
* 分配的ip设置
在文件末尾添加如下内容：
```
localip 10.10.10.0
remoteip 10.10.10.230-250
```
localip 是 VPN 服务器 IP，可任意指定。
remoteip 是可分配给 vpn 客户端 IP。
:wq保存退出vim
* dns设置:
编辑`vim /etc/ppp/pptpd-options`
找到并编辑ms-dns,去掉注释
```
ms-dns 172.31.0.2
ms-dns 8.8.8.8
```
173.31.0.2是亚马逊内部的dns，8.8.8.8是google的dns

## 添加vpn用户
编辑:`vim /etc/ppp/chap-secrets`
```
# Secrets for authentication using CHAP
# client        server  secret                  IP addresses
vpn     pptpd   pwd     *
```
用户名vpn，服务器名pptpd(保持和pptpd-optins里面的设置一样)，pwd密码，*是允许任何ip连接该服务器

## iptables防火墙设置
* 开启ip转发
`vim /etc/sysctl.conf`
找到net.ipv4.ip_forward去掉注释，并设置成1
```
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
```
生效设置:`sysctl -p`

## 设置 iptables NAT 转发
`iptables -t nat -A POSTROUTING -s 10.10.10.0/8 -o eth0 -j MASQUERADE`

10.10.10.0/8是根据第二步设置的ip地址范围设置的。
如果要开机生效，可以把上面两行iptables命令写入/etc/rc.local的exit 0 前面：
```
iptables -t nat -A POSTROUTING -s 10.10.10.0/8 -o eth0 -j MASQUERADE
exit 0
```

## 启动pptp服务：
`/etc/init.d/pptpd start`
