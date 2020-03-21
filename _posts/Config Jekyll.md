---
layout: post
title: 配置 Jekyll
image: ''
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
<img alt="" src="/images/pages/20200321/1.png"></img>

仔细对比后发现，原本的位置应当显示为
```
https://tkaray.github.io/tkaray/
```
但是这里却少了一部分。如果配置了自定义域名自然不需要考虑这个问题，但是如果用默认域名就需要修改配置。

在网上继续检索，Stack Overflow 上有人给出了可能的解决方案：

[]()