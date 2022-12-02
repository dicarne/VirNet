# VirNet
N2N的用户界面包装。其中Tap驱动和n2n的`edge.exe`不在源码库中，可以在`Release`的压缩包中找到。

## 使用说明
下载并解压`Release`版本。

以管理员权限运行`VirNet.exe`，输入n2n的supernode的地址（域名、ip，包括端口），手动指定这个机器的IP，网络的名称和密码。

点击`连接`。第一次可能需要安装Tap网络驱动。

![image](https://user-images.githubusercontent.com/10357789/205247005-14ecd3b4-e8fa-4a97-b0cc-1a227e8add2f.png)

## 说明
### 管理员权限
根据配置自动修改网卡ip需要用到管理员权限，因此每次修改ip后的连接都需要管理员权限。

但如果一直使用同一个IP，那么只有第一次需要管理员权限，之后可以直接运行。

### 技术
本项目使用godot4.0编写。
