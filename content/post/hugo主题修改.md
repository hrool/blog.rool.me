+++
date = "2015-11-02T16:29:33+08:00"
comments = true
title = "hugo主题修改"
categories = [ "技术" ]  # 技术,思绪,生活 
tags = [ "hugo","博客","主题","js","标签云","目录" ]
+++

hugo虽然有很多的主题可以选择,不过大多都不能直接使用,借鉴了很多的其他人的Hugo的主题:

* [coderzh](http://blog.coderzh.com/)技术牛人的博客
* [青砾](http://www.chingli.com/)清新,干净,极简
* [Nanshu Wang](http://nanshu.wang/)一个程序媛的博客,主要借鉴了hugo的开发者spf13的主题
* [hugo官网](https://gohugo.io/)虽然很多英文,但是真要修改主题,这里才是帮助最多的地方
最后修改后的代码都放在我的[github](https://github.com/roolcz)上面,有需要借鉴的可以直接去clone
<!--more-->

## 我的需求
* nav导航我想按照categories来生成
* 文章显示关联的tags
* 有tags标签云
* 单个文章在需要的时候显示toc目录

## 选择一款基础的主题
hugo官网的主题,有很多,但是,很多主题是有bug的,不能直接拿来使用,而且安装的时候,必须好好查看每个主题的说明,要不然会出问题


### beg,hyde之间的纠结
外观上面,我第一时间觉得hyde更OK,极度精简,和谐,beg看起来的更传统一点,没什么新意,看起来容易疲劳的感觉,但是默认的时候hyde的分类没有beg那么明显,因为要在选择主题的基础上修改,所以就选择了beg.


### beg的问题
刚安装好beg,然后发现了几个问题:

#### beg显示tags分类的url有问题
调试的时候,[http://localhost:1313/tags/](http://localhost:1313/tags/)里面点击开对应tag的链接,发现显示的url是`http://localhost:1313/tags/tags/key`,多了一个tags,导致404错误.
#### 官网上beg的配置介绍用的yaml
虽然yaml和toml我都不熟悉,但是我就是想用toml.

## 修改主题的细节

### 修改的办法
beg主题安装在`themes/beg`文件夹下面,修改的时候,最好不要直接修改这个文件夹,而是把对应的文件拷贝的工作目录里面去,用Hugo命令生成文件的时候,会覆盖themes文件夹下面的文件.
#### 例子
前面不是说,beg的tags分类url有问题么,查了后发现,是受`themes/beg/layout/_default/terms.html`控制,首先拷贝要编辑的文件:
```shell
mkdir -p layout/_default
cp themes/beg/layout/_default/terms.html layout/_default/
```
然后编辑文件`layout/_default/terms.html`,我这边只改了一小段:`href="{{ $data.Plural }}` -->> `href="/{{ $data.Plural }}`;就是多加了一个`/`.重新运行本地调试环境:
```shell
hugo server --theme=beg  --buildDrafts --watch
```
可以找到tags的标签URL已经对了.

### 根据主题编辑站点配置文件config.toml
每个主题需要设置的变量和变量名字都不一样,所以一定要根据主题的介绍来设置.beg默认的介绍是用config.yaml,我这不转成toml文件,hugo都认可.:
```toml
BaseUrl = "http://blog.rool.me"
LanguageCode = "zh-CN"
Title =  "rool's blog"
DisablePathToLower = true
MetadataFormat = "toml"
Theme = 'beg'
paginate = 10

[permalinks]
    post = "/:year/:month/:day/:title/"  # 保留日期和标题的同时,尽量的短.
[Indexes]
    tag = "tags"
    categorie = "categories"
[Params]
    Author = "rool"
    DateForm = "2006-01-02 15:04:05" # go语言的时间格式设置有点有趣的就是这个,用的2006-01-02这个特殊时间来设置,时分秒都要一样哦.
    GoogleAnalyticsUserID = ""
    Facebook = ""
    Twitter = ""
    Github = "roolcz"
    ShowRelatedPost = true
    #Disqus = "unresolved"
    Duoshuo = "rool"  # 我这里用的国内的多说,毕竟国内用qq的比较多一点.
    SyntaxHighlightTheme = "github.min.css"
```



### 修改header,按照categories显示

参考官网的教程[taxonomies](https://gohugo.io/taxonomies/overview/)来设置.
主要是侧栏也有tags,这个和导航条上面的tags功能重复了,所以我选择导航条上用categories,因为categories我一般只有三个类型`技术`,`思绪`,`生活`,而按照我的习惯,一般的tags,一个文章可能会写上十几个...
文件是`layout`下面的`partials/default_head.html`
默认的导航条是写了`tags/`这个url,但是我要用categories来生成,所以有了以下代码:
```
{{ $baseurl := .Site.BaseURL }}
{{ range $key, $value := .Site.Taxonomies.categories.ByCount }}
<li><a href="{{ $baseurl }}/categories/{{ $value.Name }}">{{ $value.Name }}</a></li>
{{ end }}
```

### 修改侧栏的tags显示为标签云(tagcanvas)

等我加上一些文章上去后,发现tags的默认列表就已经很长了,几十个tags列出来,相信是很乱的,于是就决定把tags显示改成标签云,这样就在页面上的展示就不会太长.
文件是`partials/sidebar.html`

#### tagcanvas介绍
一个用html5的canvas功能和js实现的标签云.功能很多,有很多定制的.

#### 下载tagcanvas
tagcanvas有jquery版本的,但是引入jquery可能会和原来的主题冲突,所以我用标准javascript版本的,也不容易冲突.
去[tagcanvas官网](http://www.goat1000.com/tagcanvas.php)下载`tagcanvas.min.js`放入本地的`static/js`目录

#### 替换原来sidebar的tags
文件内容主要如下
```javascript
<div class="list-group">
<script src="{{ .Site.BaseURL }}/js/tagcanvas.min.js" type="text/javascript"></script>
<div id="myCanvasContainer" style="text-align:center;">
<canvas  width="250" height="250" id="myCanvas">
<ul>
{{ $baseurl := .Site.BaseURL }}
{{ range $key, $value := .Site.Taxonomies.tags.ByCount }}
<li><a href="{{ $baseurl }}/tags/{{ $value.Name | urlize }}" data-weight="{{ add 15 (add (mod $key 2) (mod $value.Count 50)) }}" >{{ $value.Name }}</a></li>
{{ end }}
</canvas>
</ul>
</div>
<script type="text/javascript">
var gradient = { 0: "#f00", 1: "#00f" } //颜色由红到蓝
//页面载人完成后开始画图,显示标签云
window.onload = function() {
TagCanvas.maxSpeed = 0.01;
TagCanvas.reverse = true;
TagCanvas.initial = [0,-0.1];
TagCanvas.outlineColour = '#f96';
TagCanvas.outlineThickness = 2;
TagCanvas.wheelZoom = false;
TagCanvas.weight = true;
TagCanvas.weightMode = "both";
TagCanvas.weightFrom = 'data-weight';
TagCanvas.weightGradient = gradient;
TagCanvas.Start('myCanvas');
};
</script>        
</div>
</div>
```
每个参数的相信作用最好去官网看,这边我主要是定制了显示的颜色,初始转动的方向,加上自动设置权重(主要按照tag的数量,以及其他的.),不允许客户端缩放(因为缩放后显示效果差.不协调)

### 添加文章的内容导航目录
hugo默认用变量`{{ .TableOfContents }}`来显示目录的内容,目录层次主要是一句markdown的主题标签和列表等.
#### 在`_default/single.html`文件中添加目录内容
我计划是放在右边的sidebar下面
```
<div class="col-md-4">
{{ partial "sidebar.html" . }}
</div>
<div id="toc" class="col-md-4" style="position:fixed;right:0;top:1500px;">
{{ .TableOfContents }}
</div>
```
#### 用js设定目录的位置
当文章内容少的时候,没有看目录导航的需要,当文章内容多的时候,又最好能在右边一直都显示目录,这样更人性化一点,所以我需要设定当sidebar的标签云在浏览器界面top下出现的时候,目录紧跟着其下方,当sidebar的标签云在浏览器界面top以上的时候,目录能一直固定在浏览器界面的右上方.问了同事,发现css不好实现,用js比较好,

需要用js检查浏览器界面滚动的事件,然后算出标签云下边到浏览器上边的位置,如果为负数,就要固定在浏览器右上边,这里检测滚动用window.onscroll,具体代码如下:
```javascript
<div id="toc" class="col-md-4">
{{ .TableOfContents }}
</div>
<script type="text/javascript">
//检查浏览器窗口的滚动事件.
window.onscroll = function(){
var toc = document.getElementById("toc");
var tag = document.getElementById("myCanvasContainer");
// 取得标签云的下边界到浏览器界面的上边界的距离
h = tag.getBoundingClientRect().bottom;
// 小于的时候,直接固定到离浏览器上边界20px处.
if (h < 0) {
              toc.style.position = "fixed";
              toc.style.right = "27px";
              toc.style.top = "20px";
              toc.style.width = "390px";
              }else{
              toc.style.position = "static";
              }
      }
</script>
```

###  添加多说评论系统
这个好办,去多说官网注册,设定好后,把代码加入模板就好.
```javascript
{{ if isset .Site.Params "Duoshuo" }}
<!-- 多说评论框 start -->
<div class="ds-thread" data-thread-key="{{ .RelPermalink }}" data-title="{{ .Title }}" data-url="{{ .Permalink }}"></div>
<!-- 多说评论框 end -->
<!-- 多说公共JS代码 start (一个网页只需插入一次) -->
<script type="text/javascript">
var duoshuoQuery = {short_name:"{{ .Site.Params.Duoshuo }}"};
(function() {
var ds = document.createElement('script');
ds.type = 'text/javascript';ds.async = true;
ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
ds.charset = 'UTF-8';
(document.getElementsByTagName('head')[0]
|| document.getElementsByTagName('body')[0]).appendChild(ds);
})();
</script>
<!-- 多说公共JS代码 end -->
{{ end }}
```
这个多说里面的`data-thread-key`是自己定义的,主要用来区分哪些评论属于哪个文章,我这直接用相对url来代替.
