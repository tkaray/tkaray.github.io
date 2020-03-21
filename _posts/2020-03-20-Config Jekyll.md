---
layout: post
title: 配置 Jekyll 遇到的坑们

---

配置 Jekyll & GitHub Pages 还有点难度。

GitHub Page 搭建有许多教程，我首先参考了少数派上的搭建指南。

- [GitHub Pages 搭建教程 - 少数派](https://sspai.com/post/54608)

但是在过程中遇到了不少的问题。

---

## 问题 1 Ruby 在国内访问速度感人

- [解决gem install无反应](https://iyaozhen.com/gem-install-taobao-ruby.html)

参考了以上文章提供的方法换成了国内源。

```Bash
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ gem sources -l
https://gems.ruby-china.com
# 确保只有 gems.ruby-china.com
```

## 问题 2 样式加载有问题

成功配置本地 Jekyll 环境后，在本地加载正常了。

但是 push 到远端后，发现样式并没有正常加载。参考网上的提示，打开控制台后发现有以下错误：
![]({{ site.url }}tkaray/images/posts/20200321/1.png)

仔细对比后发现，原本的位置应当显示为
```
https://tkaray.github.io/tkaray/
```
但是这里却少了一部分。如果配置了自定义域名自然不需要考虑这个问题，但是如果用默认域名就需要修改配置。

在网上继续检索，Stack Overflow 上有人给出了可能的解决方案：

- [Jekyll site works locally but not on Github Pages - Stack Overflow
](https://stackoverflow.com/questions/42450554/jekyll-site-works-locally-but-not-on-github-pages/47530487#47530487)

- [Can't get site.baseurl to work in jekyll - Stack Overflow](https://stackoverflow.com/questions/22514104/cant-get-site-baseurl-to-work-in-jekyll)

意识到这个问题后，在 _config.yml 中才发现还有文件夹设置：

![原来的设置]({{ site.url }}tkaray/images/posts/20200321/2.png)

改成了下面这样：

![修改后的设置]({{ site.url }}tkaray/images/posts/20200321/3.png)

样式问题解决了，可是又发现：

## 问题 3 主页加载不出来了

把 之前删除的 index.md 恢复出来之后，才意识到好像不对劲——明明应该是博文列表的主页，为什么会这样呢？

- [撰写博客 - Jekyllcn](http://jekyllcn.com/docs/posts/)

才意识到自己的 post 直接写的名字……

以上的文章中提到了，post 的名字有一定的要求：
```
年-月-日-标题.MARKUP
```
这样才可以正常显示出来。

由于看到可能因为时间超过当前日期会导致无法显示，就改成了昨天发布的。好像终于成了？

## 问题 4 图片引用？

重新加载之后，发现图片的现实还有问题：大家怎么都没加载出来呢？

还是刚才这篇文章给出了引用图片的正确形式：
```
由于 Jekyll 的灵活性，有很多方式可以解决这个问题。一种常用做法是在工程的根目录下创建一个文件夹，命名为　assets 或者 downloads，将图片文件，下载文件或者其它的资源放到这个文件夹下。然后在任何一篇文章中，它们都可以用站点的根目录来进行引用。这和你站点的域名/二级域名和目录的设置相关，下面有一些例子（Markdown 格式）来演示怎样利用 site.url 变量来解决这个问题。

… 从下面的截图可以看到：
![有帮助的截图]({{ site.url }}/assets/screenshot.jpg)
```

所以应该把图片链接写成
```
[]({{ site.url }}/images/posts/)
```
然后，遇到了和前面一样的问题:子文件夹会出问题……所以就应该写成
```
![]({{ site.url }}{{ site.baseurl }}images/posts/)
```
然后要和 _config.yml 中的设置对应（把斜线配合起来，连着两个就尴尬了），然而好像还没有写成 tkaray/ 更简洁一点。



