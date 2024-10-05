---
layout: post
title: CP2K 在 Docker / Singularity 容器中的安装 (v2022.1)

---

2024.10.05 更新: 请使用 docker pull 的办法拉取, 这样更方便, 流程见[链接](https://github.com/cp2k/cp2k-containers) 


这是一篇关于cp2k 2022 版本 docker 镜像, 和基于 docker 镜像转换的 singularity 文件的安装记录.
cp2k 2022 版本中不再有基于 toolchain 的 dockerfile, 而是直接使用 docker 自动编译 toolchain 与 cp2k 本体, 这使其编译过程更加方便. 
参考链接:

1. [[CP2K] docker-singularity方法安装可随意移植的cp2k](http://bbs.keinsci.com/thread-25773-1-1.html)
2. [cp2k-docker-readme](https://github.com/cp2k/cp2k/tree/master/tools/docker)
3. [GROMACS-NVIDIA NGC](https://catalog.ngc.nvidia.com/orgs/hpc/containers/gromacs)


## docker 版本的安装方法

docker 部分安装较为简单, 只要参考官方指南[cp2k-docker-readme](https://github.com/cp2k/cp2k/tree/master/tools/docker)即可. 需要注意的是为了后续 singularity 部分编译正常, 我们使用的 cp2k repository 需要是 git clone 下来的目录, 并切换到对应发行版版本:

```bash
git clone https://github.com/cp2k/cp2k.git
cd cp2k
git checkout 71f6a37
```

如果下载的是源代码, 可能会因为没有下载其他 git repository 而报错, 此时需要按照屏幕指示 clone 对应的 repo:

```bash
git submodule update --init --recursive
```

现在可以开始使用 docker build 了. prod_psmp 对应了最常使用的版本.

```bash
docker build -f Dockerfile.prod_psmp --build-arg GIT_COMMIT_SHA=$(git rev-parse HEAD) -t cp2k_prod_psmp ../../
```

网络速度好的时候, 编译过程需要半小时以上, 但网络不好的时候可能半天也完事不了. 所以选择一个较好的网络环境和时间吧.

当全部编译完成后, 可以使用官方指南中的方法试一下:

```bash
docker run -it -v "$(pwd)":/mnt cp2k_prod_psmp mpirun -np 8 cp2k -i test.inp -o test.out
```

运行程序, 但请注意, 这种方法每次都会新建一个 docker 容器, 时间久了就会堆的越来越多...

```bash
docker ps -a
```

使用如上命令可以发现每次运行都会多一行容器数据, 最后会变得乱作一团..... 因此我们应当选择如下两种替代方案:

a. 使用一个固定的工作目录, 第一次使用 run 命令创建, 之后使用 exec 进入容器后运行:

第一次运行时:

```bash
cd /the/work/directory
docker run -it -v ${PWD}:/mnt cp2k_prod_psmp /bin/bash
```

选择将当前目录挂载到虚拟机内 /mnt 的主要原因是 cp2k 的虚拟机已经将 /mnt 文件夹作为起始目录.

之后运行时:

```bash
docker ps -a # 查看对应的容器 ID
docker start 3e15825f13fb # 这里替换为想要的 ID
docker exec -it 3e15825f13fb /bin/bash
docker stop 3e15825f13fb
```

> 烦请注意, 如果关机前没有停止 docker 虚拟机中运行的进程, 关机过程可能受到影响, 同时共享文件夹可能会断开, 这个容器可能就要重新做了 (带有程序本体的 cp2k-docker 还好, toolchain 版本的直接就需要再编译一次了..)

b. 使用官方指南的方法, 但是添加 --rm 参数, 每次运行后直接删除容器, 世界都安静了:

```bash
cd /the/work/directory
docker run -it --rm -v "$(pwd)":/mnt cp2k_prod_psmp mpirun -np 8 cp2k -i test.inp -o test.out
```

## Singularity 部分的安装方法

首先将 docker 文件打包, 然后转换为 sif 文件:

```bash
docker save cp2k_prod_psmp -o cp2k2022.tar
singularity build cp2k2022.sif docker-archive://cp2k2022.tar
```

我们基于以上可以正常运行的程序, 直接使用 singularity 命令运行 cp2k 时会发现找不到 mpirun, 也找不到 cp2k, 这说明转换过程丢掉了 .bashrc 中保存的环境变量文件, 因此我们需要手动添加一次. singularity 中该环境变量保存在 /.singularity.d/env/90-environment.sh 中. 为了修改该文件, 我们需要将 sif 文件解包, 修改后重新打包.

```bash
singularity build --sandbox cp2k2022/ cp2k2022.sif
```

为了不让镜像文件变大, 直接使用物理机对环境变量进行修改, 在 90-environment.sh 中添加如下内容以找到支援程序包与 cp2k 本体:

```bash
source /opt/cp2k-toolchain/install/setup
export PATH=$PATH:/opt/cp2k/exe/local
export CP2K_DATA_DIR=/opt/cp2k/data
export OMP_NUM_THREADS=1
```

测试一下效果:

```bash
singularity exec -B ${PWD}:/mnt -H /mnt cp2k2022/ mpirun -np 8 cp2k H2O-hybrid-b3lyp.inp |tee H2O-hybrid-b3lyp.out
```
其中 -B 是类似于 docker 中的 -v 指令, 用于指定共享目录与挂在位置; -H 用于指定工作目录, 后面的则是 cp2k 的一般调用方法, 单独指定 cp2k 时调用的是 cp2k.psmp (软链接).

一切完成后, 重新打包:

```bash
singularity build cp2k2022-new.sif cp2k2022/
```

为了让之后提交的时候更方便, 我们写一个 bash 脚本用于提交文件:

```bash
#!/bin/bash
export SIF=/home/tkaray/cp2k2022.sif
export cpucores=8
singularity exec -B ${PWD}:/mnt -H /mnt ${SIF} mpirun -np ${cpucores} cp2k.psmp $1 |tee ${2:-cp2k.out}
```

保存为 submit.sh, 之后就可以用这个脚本提交文件了, 需要指定 inp 和 out 文件名, 当未指定 out 时就会以默认文件名输出.

```bash
chmod a+x submit.sh
./submit.sh test.inp test.out
```