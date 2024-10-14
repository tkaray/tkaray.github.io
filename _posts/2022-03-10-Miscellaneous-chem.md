---
layout: post
title: 杂项 - Chem Posts

---

## 1. 在ORCA中使用xTB的方法

(系统: macOS 11.0, Linux 应该也一样)
(20220406) ORCA 是通过 otools_xtb 模块调用 xTB 的, 但软件中未直接提供 xTB 的 binary. 直接拷贝过来会提示缺动态库 , 因此我们可以先将 xTB 装好, 然后添加软链接到 orca 的安装目录.

> 不太清楚 xTB 的库调用机制, 如果直接使用 binary 安装, 在 .bashrc 设置环境变量也许也可行, 操作应该类似此处的使用方法 (建立软链接).

安装 xTB (anaconda 方法):

```bash
conda create -n xtb xtb
```

安装完成后激活该环境:

```bash
conda activate xtb
```

这时可以通过 which 命令找到确切位置:

```bash
which xtb
which orca
```

然后根据上文显示的内容建立软链接:

```bash
ln -s /Users/tkaray/opt/anaconda3/envs/xtb/bin/xtb /Users/tkaray/Library/Orca501/otools_xtb
```

然后就可以正常调用了.

## 2. 之前做的关于IAST和CIE的简短教程

(20211004) 都放在b站上了。

[基于pyGAPS包计算气体吸附IAST选择性 BV1J341127PE](https://www.bilibili.com/video/BV1J341127PE)

[CIE坐标的获取与转化-通过波长、光谱得到CIE xy和RGB坐标 BV1ib4y1y7GL](https://www.bilibili.com/video/BV1ib4y1y7GL)

## 3. 批量导入 cif 结构对应文献到 Endnote 的方法

(20220616) CSD Conquest 能够完成各种各样复杂的结构搜索，但是如何把相关文献一次导入是个难题。今天发现了一个新思路，可以将 Conquest 的结果一次性都塞进 Endnote，然后再通过 Endnote 完成批量下载。

适用系统：全平台

使用软件：

- CSD Conquest （需要一个较高版本，这里使用 2022.01）
- Endnote （只要能使用 Tab Delimited 导入即可）
- 任意文本编辑器（如记事本）

步骤如下：

1. 在 Conquest 执行搜索；
2. 选好需要的结构后，和往常导出 cif 文件时一样，选择 Export Entries as...；
3. 选择 TSV: Endnote (import as Tab Delimited)，其他选项同导出 cif 设置；
4. 将导出后的文件用编辑器打开，查找 http://dx.doi.org/ 并替换删除，并将第二行的 URL 改成 DOI，保存；
5. 在 EndNote 中导入文件，并选择 Tab Delimited；
6. 新导入的文件名并不是文献标题，全选新导入的文件，右键 - Find Reference Update，然后选择全部更新；
7. 有一些文献有重复，因此需要使用 Reference - Find Duplicates 去重，大功告成！

注意事项：

1. 旧版本的 Conquest 是没有 URL 这一项的，因此可能做不到以上操作，但 2022.01 肯定可以。
2. 有一些结构没有对应发表的文章，因此会显示为 CSD Communication(Private Communication)。

## 4. 用于转换 XRD 测试数据文件的小工具 - PowDLL

(20220809) 前阵子实验室的小师妹送样 XRD, 带着数据回来后才发现是打不开的专用格式, 于是大家为了转换成可用格式找到了一个小工具 PowDLL, 用了一下感觉体积小巧功能方便, 值得推荐. (直到这时候才发现原来是 PowDLL 而不是PowerDLL)

官方网站: [http://users.uoi.gr/nkourkou/powdll]()

引用文献:

```
PowDLL, a reusable .NET component for interconverting powder diffraction data: Recent developments, N. Kourkoumelis, ICDD Annual Spring Meetings (ed. Lisa O'Neill), Powder Diffraction, 28 (2013) 137-48.
```

该软件是由 Nikolaos Kourkoumelis 课题组开发的, 最新版于今年 3 月更新, 支持格式包括 (来自官网):

```
Bruker/Siemens RAW (versions 1,2,4), Bruker BRML, STOE RAW (plus multi-range files), Scintag RAW (plus multi-range files), Rigaku RAW, Shimadzu RAW, Philips RD, Philips SD, Scintag RD, Panalytical XRDML, INEL Binary, INEL ASCII, Scintag ARD, powderCIF, Sietronics CPI, Riet7 DAT, DBWS, GSAS (CW STD), Jade MDI, Rigaku RIG, Philips UDF, UXD, XDA, XDD, CCDC Mercury XYE, XPOWDER PLV (old and new format), UDF (NEX), ProtoXRD and ASCII XY Files.
```

转换过程十分简单, 将一个或多个文件导入后选择导出格式即可, 感觉连教程都不需要了... 因为软件网站不太好连上, 就把软件发到了度盘, 如果觉得有用记得引用原文.

链接: https://pan.baidu.com/s/1qPBPrUcDJrOcHvKmf_Z50A?pwd=awsl 提取码: awsl

## 5. Gaussian 的引用要求太长了

在一篇 Nat. Commun. 看到了一种写法, 由于 Nat. Commun. 三个作者以上仅标注首位作者, 因此变得很短. 这样看起来就舒服多了.

```
Frisch, M. J. et al. Gaussian 16, Revision C.01, Gaussian, Inc.
```

## 6. 一些 EndNote 小技巧

### 导入文献去重复

导入的新文献经常会和旧文献有重叠, 但是直接通过 Find Duplicates 删除某些时候又不合适. 比如想新建一个分类, 但是新导入的文献去重后就再也找不到旧有对应的了, 或者其实有 3+ 篇文档, 比对很麻烦. 为了保证无论何种目的都能得到实现, 可以考虑在 Find Duplicates 后选择 Cancel, 这时会多出来一项 Duplicate Reference 分类, 再进行下一步操作即可.

### 修改参考文献文字样式

EndNote 的参考文献文字样式在插件中调整选项很少, 可以选择在 Word 样式窗格中手动调整 EndNote Bibliography 样式. 注意每次更新文献后都需要重新修改.

### SciFinder 导入的内容无法 Find Full Text (可能已过期)

2024.10.02 更新: SciFinder 改版了, 这条可能已经失效了.

这种时候可能是因为导入了 MEDLINE 条目, 条目没有 doi 项. 在使用 SciFinder 搜索内容时建议在得到结果时第一步只选择显示 CAPLUS, 这样就能保证一直都有 doi 了.

换句话说, 只要文章元数据的 doi 能够被正确识别, 而且有下载权限, 就能找到 Full Text.

### 解决超算无法安装和 CUDA 有关的包的方法

在使用超算时, 登录节点没有 video driver (CUDA), 因此无法配置 需要 CUDA 的包. 这时候可以参考 [Managing virtual packages](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-virtual.html) 将环境变量 CONDA_OVERRIDE_CUDA 改为想要的 CUDA 版本, 即可跳过检查.

参考链接: [Failed when trying to install deepmd-kit2.1.3&CUDA11.6 with conda](https://github.com/deepmodeling/deepmd-kit/discussions/1810#)

## 7. 压缩 PDF 文件

有的时候需要将很大很大的 PDF 压缩到 1 MB 以下, 以前一直认为是"强人所难". 但是其实有一个很好用的工具 ghostscript 能够轻松完成这一任务.

首先安装 anaconda, 已安装的就跳过这步. 然后使用 anaconda 创建环境:

```
conda create  -n ghostscript -c conda-forga ghostscript 
```

安装完成后, 激活环境. 以后每次用之前先激活环境即可.

```
conda activate ghostscript
```

提供输入文件名和输出文件名, 替换以下的 input 和 output 即可:

```
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
   -dNOPAUSE -dBATCH -dQUIET -sOutputFile=output.pdf input.pdf
```