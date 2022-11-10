---
layout: post
title: AiiDA 的配置

---

## 1. AiiDA 与 Materials Cloud

简单来说, AiiDA 可以用于计算流程管理与重现和数据的共享. 而 Materials Cloud 是一个数据与工具的分享平台. 
AiiDA 的好处在于大一统的计算流程, 可以在一个 Python 环境中解决大量数据管理问题, 在重复性计算需要不断使用脚本的场景中可以起到很大的作用. 

[AiiDA](https://github.com/aiidateam/aiida-core)

[Materials Cloud](https://www.materialscloud.org/home)

本文写于2021.04.13, 使用的系统为 RHEL 8.3, 在物理机和虚拟机中共复现两次后使用虚拟机版本 RHEL 8.3 记录 + 录制. 

## 2. 安装 AiiDA 

首先尝试了全局安装 postgresql 和 rabbitmq, 但是遇到了无法运行 py 文件、postgresql 连接莫名挂掉的问题, 所以切换成了完全的 conda 虚拟环境安装. 
不过为了万一以后还要切换回这条路, 就不删除这部分记录了. 

和 Anaconda 的 conda 命令类似, AiiDA 也有一个管理命令 verdi. verdi 的 setup 部分会采用 CLI 交互的方式, 如果中途输入错了不能回到上一步, 但是可以 Ctrl + C 退出重来. 

另外, 虚拟环境就这一点好, 实在崩了救不回来了, conda remove - n ${VENV_NAME} --all 重新来过就好了, 不怕系统爆炸. 

### 2.1 全局安装 (废弃) 

postgresql 安装:

```bash
sudo dnf install postgresql-server
```

系统会自动安装合适版本. 

配置: 

```bash
gedit /var/lib/pgsql/data/pg_hba.conf 
```

改成下面的样子 (::1/0这行比较重要) 

```bash
# "local" is for Unix domain socket connections only
local   all             all                                     trust
local   all             aiida                                     trust
local   all             postgres                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
host    all             all             0.0.0.0/0            trust
# IPv6 local connections:
host    all             all             ::1/0            trust
# host    all             all             ::1/128                 ident
# Allow replication connections from localhost, by a user with the
# replication privilege.
# local   replication     all                                     ident
# host    replication     all             0.0.0.0/0            ident
# host    replication     all             ::1/128                 ident
```

好像也有办法一次性修改 (在 aiida-vasp 插件中讲的) 

```bash
sudo sed -i 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf
```

在成功配置好后, 记得使用以下命令. 另外, 在启动时记得切换到有 aiida 的虚拟环境. 

```bash
reentry scan -r aiida
```

### 2.2 Anaconda安装方法

参考了以下教程 [Install AiiDA in Conda](https://aiida.readthedocs.io/projects/aiida-core/en/latest/intro/install_conda.html)

#### 2.2.1 创建环境+安装主程序: 

```bash
conda create -n aiida -c conda-forge aiida-core aiida-core.services
conda activate aiida
reentry scan
```

#### 2.2.2 (本不应属于此处的)插件安装

这里插一句, **所有需要使用的插件请在此时安装！**否则有的插件会 crash 掉后面需要设置的 postgresql, 解决办法只有 verdi profile delete, 或者干掉
~/.aiida 文件夹重新配置 (说的是 aiida-raspa, 其他的目前没有发现这个问题, 但是为了以防万一还是这时候做吧) . 所以在此时要提前执行一下下一段的 pip 安装: 

```bash
pip install aiida-vasp aiida-cp2k aiida-gaussian aiida-orca aiida-raspa # 或者其他你可能用得到的程序插件
```

在每次安装完类似插件后, 都要重新执行 reentry scan 命令, 否则 AiiDA 找不到. 

此外, 以下所有的配置均需要在虚拟环境中进行, 留意前面的 conda 部分是否是刚刚设置好的虚拟环境, 如果重启, 是会自动退出/换回 base 环境的. 记得换回来. 

#### 2.2.3 配置 postgresql: 

```bash
(aiida) $ cd /home/tkaray/ # 或者其他
(aiida) $ initdb -D mylocal_db
(aiida) $ pg_ctl -D mylocal_db -l logfile start
```

#### 2.2.4 配置 rabbitmq: 

```bash
rabbitmq-server -detached
```

#### 2.2.5 启动 daemon (**官网教程不适合**): 

```bash
(aiida) $ verdi daemon start 2 # 这里的数字不能超过处理器内核数目
```

这时候会报错:  **Critical: no default profile defined: none**

此时需要先运行: 

```bash
verdi quicksetup
```

！！！此处需要注意, 官网tutorial写的是先运行start后quicksetup, 但是如果按照它的顺序就会报错. 所以要反过来运行.  

Quicksetup 步骤中需要写 profile name, mail, name, institution, 其他的交给它来解决 (不需要自己配置 postgresql 的账户、密码、权限、登录ip配置管理了) . 

另外, 此处只能写 quicksetup 不能写 setup, 因为使用 setup 就需要输入 postgresql 的用户名, 然而使用 conda 环境并不能用 postgres 用户进行配置, 
因为conda环境并不会对该用户生效. 

这些做完了, 再按照官网的教程运行: 

```bash
verdi daemon start
```

#### 2.2.6 conda 虚拟环境启动时的自动运行脚本

每次启动conda的时候, 可能会出现rabbitmq, 或是postgresql没有启动的情况, 因此需要在启动conda虚拟环境的时候自动运行. 
${CONDA_PREFIX}/etc/conda/activate.d/ 中添加以下脚本: 

```bash
cd /home/tkaray/ # 改成你的用户名
pg_ctl -D mylocal_db -l logfile start
rabbitmq-server -detached
verdi daemon start
```

#### 2.2.7 其它

全部配置好后, 可以试着查看一下状态了: 

```bash
verdi daemon status
verdi status
```

如果 出现了什么设置上的问题, 需要删除 profile 再配置, 需要输入: 

```bash
verdi profile list # 看一下以前设置的名字
verdi profile delete quicksetup # 换成之前设置的名字
```

这里可以选择不删除数据库, 并在下次自动连接. 我没有对此进行尝试, 选择了直接删除. 但是如果在生产环境中, 这样的操作可能会导致数据丢失. 请万分注意选项. 


## 3 配置 Aiida 的程序插件

由于 VASP 的插件教程写的最详细, 所以在此处就继续参考它的方法了. 但是请注意, 前半段可能走不通, postgresql 会以各种方式 down 掉. 因为这折腾了好几个晚上... 所以我们仅参考以上配置后的部分. 

[AIIDA-VASP](https://aiida-vasp.readthedocs.io/en/latest/getting_started/computer.html)

### 3.1 添加新电脑

```bash
verdi computer setup
```

由于这次使用的是本机, 所以我们要做的没有教程中这么复杂. Transport plugin: 可以选择 local , 消息队列选择了 direct. 如果是远端需要使用ssh, 还需要先设置好ssh登录用的key (见上面的原教程链接) . 

Setup 过程没什么难点, 中间弹出的两次 vim 窗口, 一个是电脑运行所有 code 前会先执行的内容, 用于配置环境变量. 后面是结束后的内容. 这里会看到
要求 MPI 版本, 也就是至少要安装 intelMPI, openMPI, MPIch 中的其中一种. 
对于我们来说, 就在运行前 (第一个 vim 窗口) 写上以下内容吧:  (没有测试过不写会不会出错, 一般情况下重新 source 一次都没问题, 以防万一就一直写着了) 

```bash
source /home/tkaray/.bashrc
```

然后按照程序提示执行代码

```bash
verdi computer configure local ${YOUR_COMPUTER_NAME}
```

### 3.2 AiiDA-VASP 的安装

VASP 版本的插件在文档中写的很清楚, 其他程序也大同小异. 如果找不到 input plugin, 记得运行 reentry scan. 

```bash
% verdi code setup
Info: enter "?" for help
Label: vasp
Description []:
Default calculation input plugin: ?
Info: Default calculation plugin to use for this code.
Select one of:
      arithmetic.add
      templatereplacer
      vasp.vasp
      vasp.vasp2w90
Default calculation input plugin: vasp.vasp
Installed on target computer? [True]:
Computer: mycluster
Remote absolute path: /usr/local/calc/vasp/vasp
Success: Code<1> vasp@mycluster created
```

### 3.3 AiiDA-RASPA 的安装

关于RASPA的插件, 如果在配置好quicksetup之后安装 (如前所述) , 会带崩和 postgresql 数据库的连接. 此时需要的是删除 profile, 重新 quicksetup 连接数据库. 应该可以选择保留数据库内容, 这样就不会丢 (大概) . 但是这个操作很危险, 如果不小心删错了数据就全完蛋了. 
还好目前没有发现其他插件出现这个情况, 但是还要小心. 

```bash
# 如果你的 verdi status 显示数据库错误, 执行下面的命令, 没有错误就不要执行！！！
verdi profile delete ${PROFILE_NAME}
verdi quicksetup
```

### 3.4 关于 RASPA 安装中自己的错误

因为在verdi code setup步骤中环境变量设置有问题, 在将相对路径改为绝对路径之后写错了, 所以折腾了整整一天. 最后是在aiida-files (设置的节点暂存目录) 中挨个翻节点内容, 找到了_scheduler-stderr.txt 中的未找到共享库错误才发现的. 看来以后如果节点出错, 可以在节点暂存目录中翻翻看. 

```bash
error while loading shared libraries: libraspa2.so.0
```

这样的错误一般都是由于 LD_LIBRARY_PATH 环境变量设置有问题造成的. 所以使用

```bash
verdi code delete raspa
verdi code setup 
```

重新设置一下运行前变量就好了. 