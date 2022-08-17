---
layout: post
title: RASPA 的安装与使用

---

@tkaray CC-BY-NC 4.0 

本文是基于 RASPA manual 的设置攻略 (v 2.0.45), 带有一些个人补充的注释内容. 部分内容没有特别合适的翻译则会使用英文原文. 限于能力所限本文的内容可能有部分纰漏, 请酌情参考. 所有补充的注释内容均使用以下方法标记:

> Note: 建议使用 Linux 和 macOS 安装.

## Part 1. 简介

RASPA是由 Randall Q. Snurr, Sofia Calero, David Dubbeldam, T.J.H. Vlugt 等研究者开发的经典模拟软件包, 可以用于模拟气体, 流体, 沸石, 硅铝酸盐, MOF, 碳纳米管等材料.

引用文献: (来自于 GitHub 的介绍页)

* D. Dubbeldam, S. Calero, D.E. Ellis, and R.Q. Snurr, "RASPA: Molecular Simulation Software for Adsorption and Diffusion in Flexible Nanoporous Materials",
   Mol. Sim., 42 (2), 81-101, 2016.
   [link to article](https://www.tandfonline.com/doi/full/10.1080/08927022.2015.1010082)
* D. Dubbeldam, A. Torres-Knoop, and K.S. Walton,  "On the Inner Workings of Monte Carlo Codes",
   Mol. Sim. (special issue on Monte Carlo) 39(14-15), 1253-1292, 2013.
   [link to article](http://www.tandfonline.com/doi/full/10.1080/08927022.2013.819102)
* D. Dubbeldam and R.Q. Snurr, "Recent developments in the molecular modeling of diffusion in nanoporous materials",
   Mol. Sim., 33 (4-5), 305-325, 2007.
   [link to article](http://www.tandfonline.com/doi/abs/10.1080/08927020601156418)
* D. Dubbeldam, K.S. Walton, T.J.H. Vlugt, and S. Calero, "Design, Parameterization, and Implementation of Atomic Force Fields for Adsorption in Nanoporous Materials",
   Adv. Theory Simulat., 2(11), 1900135, 2019.
   [link to article](https://onlinelibrary.wiley.com/doi/full/10.1002/adts.201900135)



## Part 2. 安装, 编译与运行

### 自行编译

RASPA 是由 C 语言写成的, 因此需要一个 gcc 或 icc 编译器. 

> Note: 建议使用 Linux / macOS 系统运行()

```BASH
export RASPA_DIR=/path/to/environment/root
rm -rf autom4te.cache  
mkdir m4  
aclocal  
autoreconf -i  
automake --add-missing  
autoconf  
./configure --prefix=${RASPA_DIR}  
# or ./scripts/CompileScript/make-gcc-local  
make  
make install  
```
> Note: cd 到对应目录后直接运行即可. RASPA_DIR 为目标安装位置.

### 使用 conda-forge 源

也可以使用 Anaconda 的方式安装预编译版本.

```BASH
conda install -c conda-forge raspa2=2.0.45
export RASPA_DIR=/path/to/environment/root
# e.g. export RASPA_DIR=/Users/leopold/Applications/miniconda3/envs/raspa-env
```

> Note: Conda-forge 版本的软件本体在 /path/to/anaconda3/envs/envs-name/bin/simulate, 支持文件在 /path/to/anaconda3/envs/envs-name/share/raspa下.  因此, RASPA_DIR 环境变量设置位置应当位于虚拟环境目录处, 此时和自行编译的情况相同.

> Note: (2022年3月5日记) 即使使用 conda-forge 源的预编译方法安装, 也应该下载 GitHub 版本, 因为其中有一些教学示例 demo 是预编译方法未提供的. 此外, GitHub 源目前仅含有部分 example forcefield & molecules, 但 conda-forge 源有更多示例用的力场和小分子文件. 因此, 建议两个都装, 然后合并到一处.

> Note: (2022年3月6日记）发现 conda-forge 源更新后也没有那么多参考文件了，所以需要手动指定2.0.45版本获取这些文件. 手动指定版本的方法见上面的命令.

> Note: 还需要注意的是, 所有的教学示例 demo 均指定了~目录下的文件夹, 如果不想每次运行示例都改提交文件, 请在家目录对对应位置使用 ln -s 建立软链接.

### 文档编译与下载

虽然 GitHub 中提供了 tex 编译的选项, 但是有已经编译好的版本在 iRASPA 的主页: [Link](https://iraspa.org/raspa/)

### 运行

> Note: RASPA的运行需要多个文件. 其中, simulation.input 文件控制运行过程, 一个运行脚本负责设置环境变量和调用主程序 simulate. 具体可以参考 GitHub repo 中的 example/ 文件夹下的内容. 如果需要使用 mpi 则需要在提交脚本中使用 mpirun 调用. 暂不清楚安装过程中使用的 mpi 和运行时是否需要保持一致, 总之保持一致就好了. 有多个可以用 login shell 在提交脚本中引用想使用的 mpi.

### 使用 AiiDA 调用

> Note: 通过安装 AiiDA 框架和交互组件 aiida-raspa 可以实现基于 Python 的控制. 具体方法可以查看 aiida-raspa 的 GitHub repo 的 demo.

### 工程文件的种类

- simulation.input

    包含模拟类型, 模拟的步数, 骨架名字, 晶胞数目, 使用的小分子, Monte-Carlo 行动 (move) 类型等控制词条.

- structure-name.cif

    如果使用了一个骨架 (如沸石和 MOF), 则需要提供一个 CIF 文件, 该文件名的前半部分需要在 simulation.input 中进行指定.

- pseudo_atoms.def

    列举使用的赝原子的信息, 包括电荷和质量等. 一般情况下赝原子代表一个原子, 但也可能代表一个小基团 (比如 -CH3). 由于 CIF 文件会提供原子信息, 因此在 CIF 中列举的原子并不需要在赝原子列表中进行规定, 当读取 CIF 文件时原子信息将自动加入到该列表中. 如果在赝原子中也提供了原子信息, 那么该文件中的数据将被优先读取.

- force_field_mixing_rules.def 和 force_field.def

    赝原子列表中每个原子所使用的力场参数. 这些参数包括 Van der Waals potential 类型和其他参数, 如是否使用尾部校正 (tail correction), 是否在 cutoff 之后将作用置零, 还有 mixing rule 的类型等.

    在文献中报道的力场参数主要包括两种类型, 第一种会提供每个原子的势能参数和 mixing rule 的列表, 第二种则会提供原子对和参数. 第一种对应 force_field_mixing_rules.def, 第二种则对应 force_field.def. 其中, force_field.def 的优先级高于 force_field_mixing_rules.def.

## Part 3. 程序运行参考

前段中介绍了 RASPA 的安装过程, 这方面的中文文章有不少, 但是目前关于如何让 RASPA 正常运行的分享貌似还没有. 这一次来聊聊如何使用 RASPA 进行计算, 让软件可以针对自己的结构跑出结果. 由于作者水平有限, 以下部分必有错漏之处, 而且不保证获得的结果的准确性, 请在阅读后多多尝试, 同时参考原版手册和其他资料. 

1. GitHub Repo. Link: https://github.com/iRASPA/RASPA2
2. RASPA Manual. Link: https://iraspa.org/raspa
3. B 站的 RASPA Workshop 存档. BV1Hr4y1V7o7
4. 2.0.45 版本的 RASPA 源代码.  https://github.com/iRASPA/RASPA2/archive/refs/tags/v2.0.45.zip 单独拿出来是因为新版本删除了一些示例文件 (力场、分子等), 可参考的内容变少了. 把这一版本的代码下载下来, 参悟其中的设置吧. 此外, 还有几个 PPT 可以参考 (不太方便放), 需要的话可以私聊我. 

### 使用 RASPA 的示例文件

个人建议是至少看一遍源代码中 Tutorial 的 AdsorptionN2InMIL-47 部分, 都跑一遍看看效果 (对应手册第八章). 其他的也可以跑跑看, 只需要运行 run 即可. run 文件的内容如下:

```bash
#! /bin/sh -f
export RASPA_DIR=${HOME}/RASPA/simulations/
export DYLD_LIBRARY_PATH=${RASPA_DIR}/lib
export LD_LIBRARY_PATH=${RASPA_DIR}/lib
$RASPA_DIR/bin/simulate $1
```

为了能够让程序直接转起来, 如果使用了 Anaconda 安装, 需要按照上一篇文章中的设置软链接. 同时, 该程序默认并未使用 MPI, 为了运行速度够快, 我们还需要开启多核并行. 

### RASPA 多核运行方法

建议使用 OpenMPI. 建议不要使用 apt / dnf 方法安装 (可能不方便切换), 而是选择源代码编译. 编译过程可以参考 Sobereva 老师的 ORCA 安装方法(http://sobereva.com/451) 中相关部分, 另外如果之后也用 ORCA 5+, 需要保证 OpenMPI 编译前 gfortran 已被安装 (否则这个 OpenMPI 只能给 RASPA 用). 在编译完成并设置好环境变量后, 可以把 run 文件中的代码改成

```
mpirun -np 物理核心数目 $RASPA_DIR/bin/simulate $1
```

如果已经把 RASPA 的环境变量都写进了 .bashrc, 也可以不借助 run 文件, 而是直接在 terminal 中全路径运行 simulate 进行模拟.

```bash
mpirun -np 物理核心数目 $RASPA_DIR/bin/simulate
```

如果成功把这些示例弄完了, 就进入下一环节: 尝试自己的吸附模拟. 

### RASPA 骨架与小分子结构设置

对于一个最小的可运行文件配置, 骨架结构文件, 小分子结构文件和力场参数文件三者必不可少. 在设置结构与力场过程中, simulation.input 和其他文件的匹配至关重要 (否则程序就会爆炸). 因此, 我们需要同时在 simulation.input 文件与 $RASPA_DIR/share/raspa 文件夹中保持一致. 该文件夹中共包含四部分, 分别代表:

- forcefield 存储原子的 L-J 势, 每个文件夹名字代表其名称;
- framework 存储骨架结构键, 键角, 二面角的伸缩扭转等参数 (非必须);
- molecules 存储吸附的小分子结构信息, 每个文件夹名字代表其种类;
- structure 根据骨架类型存储的骨架结构文件, 一般可以和 simulation.input 一起提供, 不用管这个文件夹.

本节先说骨架结构和小分子结构, 骨架结构对应 simulation.input 的 Framework 部分, 一般使用 CIF 文件, 如果使用其他类型的文件, 可能需要设置 InputFileType 词条. 参考示例中的写法, 在 simulation.input 中结构名称应当写在 FrameworkName 部分, 且去除后缀名.

有时候 CIF 文件的对称性无法被正确识别, 此时可以使用一些软件 (比如 MS) 将其转换为 P1 对称性再计算. 

此外, 原子电荷可以使用 CP2K 计算 (参考 http://sobereva.com/587), 并将电荷添加到 _atom_site_charge 条目中. 此时需要将 UseChargesFromCIFFile 设置为 yes.

小分子结构需要提供许多参数, 如果下载了之前的代码, 也就有了最初可用的参数了.  MOF 文章中很多都在用 TraPPE, 参考着相关文献做吧. 小分子对应 Component 部分, MoleculeName 写去除后缀的文件名, MoleculeDefinition 写**文件夹名字**. CreateNumberOfMolecules 为最初的分子数, 其他的看情况修改. 注意正式使用时这里也应该引文献.

### RASPA 结构与小分子力场设置

RASPA 的 forcefield 是最头痛的地方, 一般报错都因为这里设置存在问题. 最基础的设置只需要修改 force_field_mixing_rules.def 文件中的内容, 根据文献设定力场参数. 注意 number of defined interactions 一定要与后面的条目数相同, 否则会少读取内容. 对于 MOF 材料来说一些高通量筛选文章的 SI 会提供其使用的参数, 同时 TraPPE 可以直接在其网站查到. 缝缝补补总是能把这些凑齐的.

如果报错内容为

'force_field.def' file not found and therefore not used

可以不用理. 如果提示原子无定义并退出, 则需要在 forcefield 中补充 molecules 和 CIF 中未定义的原子参数 (复现不出来这条错误的英文了). 力场信息对应 simulation.input 文件中的 Forcefield 条目, 需要将文件夹名与该条目匹配. 不同设置项对应的文件夹名称可能是相同的, 最初因为这一点折腾了很久也找不到为何报错.

### 其他内容

ExternalTemperature 和 ExternalPressure 可输入的并不是单一的值而是数组, 因此可以一次性在一个文件中提交许多个压力, 这样可以一次性算很多点.

Forcefield 的 CutOff 和普通的分子动力学模拟类似, 不能大于整个三维结构中最短边的一半, 如果体系较小, 就需要设置超胞.

还有一些不太好归类的内容, 如果后续想到更多会在这部分补充. 复杂一些的报错我也见得较少, 可能需要查 manual 或到官方论坛咨询. 只要有大量可参考的输入文件和已报道文献, 总能把想要做的模拟跑出来的. 加油吧~
