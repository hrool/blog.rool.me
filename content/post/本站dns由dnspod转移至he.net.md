+++
date = "2014-12-26T20:33:38+08:00"
title = "本站dns由dnspod转移至he.net"
categories = [ "技术" ]
tags = [ "dns","博客",'dnspod','he.net','域名','解析' ]
+++

## 发现问题
1. 发现paypal的邮件在rool.me收不到，查看了很多原因，优化了postfix，最后还是不能收到，原来是paypal的服务器查询不到rool.me的dns记录，估计dnspod在国外做的不好
2. 在公司连接本站的时候，经常出现连接不到地址的情况，ping rool.me一下，才发现没有dns记录，难道是dnspod在国内也抽风，虽然我用的是免费套餐，但是出了这个问题也难受。
<!--more-->

## 考虑迁移dns
考察发现HE.NET在国外的评价挺好，故而决定转移dnspod至he.net

## 操作流程
1. 访问[https://dns.he.net](https://dns.he.net/)注册一个账号
2. 在he.net的面板里面添加好需要解析的域名，dns记录,ttl都设置成300(5分钟)。网页会提示ns记录不对，先忽略
3. 去godaddy设置ns记录到he.net，一共有五个ns1-ns5.he.net

## 效果
paypal的邮件能收到了，在公司访问dns也正常解析了

## 后续
网页上提示ns1.he.net不支持ipv6，虽然我不用ipv6但是，网页一直有个提示，烦人，就把ns1去掉了，然后去godaddy上也把ns1的记录去掉
