---
layout: post
title: Tools / 一些有用的小工具
date:  2026-07-27
---


## 将UV-Vis和荧光光谱转换为CIE和RGB的工具

在 Codex 的帮助下 vibe 了一个从紫外吸收谱和荧光谱到 CIE 和 RGB 值的工具, 目前还是一个 demo, 如果内容有问题可以提 issue 或者直接联系我修改.

[UVVis-FL-to-RGB](https://tkaray.github.io/UVVis-FL-to-RGB/)


## 让 MacBook 合盖也不会睡眠的小脚本

方便合盖使用, 不过最好不要在 Intel MacBook 上尝试, 会热坏电脑. 也不要跑太高的负载.

[查看或下载 mac-sleep-toggle.sh]({{ '/assets/scripts/mac-sleep-toggle.sh' | relative_url }})

脚本会调用 `sudo pmset` 修改系统级电源设置. `sleep` 命令会写入固定的 10 分钟睡眠参数, 不会自动还原此前的自定义数值.

## 其它工具待开放中...

还有一些其它的很有意思的工具, 后续做好了会开放.
