# 使用说明

updated in 2025.1.17 by WuYuda

程序使用Matlab编写。

`data`里面是原始数据，请先把`getIMUdata(Base)`程序里面的链接改成原始数据对应位置，跑一遍`getIMUdata(Base)`把重要的处理后的数据存下来。

## 姿态

关键的算法在自定义库`quaternion_library`以及`getIMUdata(Base)`里面。如果要学习，请参考四元数的有关内容（学姐资料）。`Rotate_Model`只是一个可视化模型。

## Kellman算法

笔者正在学习和更新中。

核心是通过不同的测得不太准的数据融合出一组测得准的数据，用来估计速度和位置。