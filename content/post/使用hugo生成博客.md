+++
date = "2015-10-29T14:10:02+08:00"
title = "使用hugo生成博客"
categories = [ "技术" ]
tags = [ "hugo","go","博客","static","webhook","github","aws",'S3','cloudfront','静态' ]
content = true
+++

## 选择hugo
以前使用aws的ec2,搭建wordpress,放置博客,php比较耗内存,还需要一个数据库,偶然之间看见了静态博客的文章,就萌生了迁移到静态博客的想法,主要由以下原因:

* 个人博客,完全不需要用户管理等一大堆的东西,所以理论上其实是不需要数据库的.
* 迁移方便,纯静态的,设置只需要一个nginx就行了
* 专注于写作,本地使用自己喜欢的编辑器,改完后,push到远程仓库上面去就行了.
* 对比了其他的,包括pelican,octopress,然后单纯的因为hugo开发环境更方便搭建,选择了hugo.

[Hugo主页](https://gohugo.io/)很漂亮,在官网可以查到很多文档,虽然大部分是英文,但是很详细.
<!--more-->
## 开发环境搭建

用的最多的操作系统是OS X和debian,笔记本用的OS X最多,使用的服务器都用的debian,我计划调试的时候用笔记本,这样在什么地方都能写,最后用debian生成最后的部署文件.

### OS X系统
OS X下面的安装非常的方便,(假设已经安装好了brew,因为对于苹果下面的开发者来说,真的是非常有必要的一个东西.):

`brew install hugo`

### debian系统
debian下面的安装,在github的hugo项目下载已经编译好的二进制程序,点[这里](https://github.com/spf13/hugo/releases):

`sudo dpkg -i hugo_0.14_amd64.deb`

## 配置hugo
### 新建站点
比较简单,一句话搞定
`hugo new site path/to/site`

这个会在`path/to/site`目录下面建立一些必要的文件和目录结构.
### 新建页面
```bash
cd /path/to/site
hugo new about.md
```
会新建一个文件在`content`文件夹下面:
```
+++
date = "2015-01-08T08:36:54-07:00"
draft = true
title = "about"

+++
```
### 安装主题
```bash
git clone --recursive https://github.com/spf13/hugoThemes themes
```
### 使用主题,测试
`hugo server --theme=hyde --buildDrafts --watch`

这个会用hyde主题来启动,并且测试,在浏览器打开[http://127.0.0.1:1313/](http://127.0.0.1:1313/)就可以看见效果,`--watch`选项主要是为了使content发生改变的时候,实时改变效果.

### 生成部署
`hugo --theme=hyde`

生成的最后文件在public里面,直接把整个文件夹copy或者rsync到需要部署的地方去就行.

### 配置
`config.toml`里面可以设置一些常用的,比如语言,作者,评论系统的id等.
`static,layout`等里面可以放一些自定义的东西,来替换主题的内容.

## 托管github
注册github账号,新建git仓库,把刚才的`path/to/site`作为内容提交上去.我这边的地址是:[https://github.com/roolcz/blog.rool.me](https://github.com/roolcz/blog.rool.me)
## 使用jenkins来作为webhook持续集成.
因为jenkins我一直用来作为持续集成用,比较熟悉,刚好又看见github上面service里面刚好有针对jenkins的.
### 在免费ec2里面安装jenkins
`apt-get install jenkins && service jenkins start`

PS:jenkins如果使用nginx作为前端的话,最好按照jenkins的文档设定nginx的配置:
[Running+Jenkins+behind+Nginx](https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Nginx ) 
### jenkins设定
1. 添加用户,打开认证,还有就是关闭注册
2. 添加`GitHub plugin`插件
3. 添加job
4. 设定job

设定和github之间的关系,有两种方式,详细的就看`GitHub plugin`插件的说明,我这里图省事,就选择最简单的办法.

* 配置`GitHub project`为你的项目在github网页上的访问地址
* 源码配置里面设定`git`,设定为项目的git地址和分支
* 触发里面选中`Build when a change is pushed to GitHub`
* 构建里面添加`Execute shell`,主要内容大致会是hugo命令生成站点以及push到github的page上面去.

### github设置

* 在项目的设置里面添加service(不是webhook),因为webhook的配置要麻烦些,可以认为service是已经配置好的webhook?
* service的名称选择`Jenkins (GitHub plugin)`
* Jenkins hook url的内容就是刚刚安装的jenkins的url加上用户名和密码:
`http://user:pwd@jenkins.domain:port/github-webhook/`
内容根据自己刚刚设置jenkins的时候的设置修改好.

### push改变到github
随便提交一个commit到github上去测试下jenkins执行job了没有.还可以看看各种状态.
