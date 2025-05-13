# 🚀 NockChain macOS 安装与运行教程

本文档将手把手指导你如何在 **macOS** 系统上安装并运行 [NockChain](https://github.com/zorp-corp/nockchain)。

适用于：
- macOS Ventura / Sonoma
- Apple Silicon (M1/M2/M3) 或 Intel 芯片
- Homebrew 包管理器已安装（如未安装请先访问 https://brew.sh 安装）

---

## 📦 第一步：准备安装脚本

打开终端（Terminal），进入你下载脚本的目录，例如：

```bash
cd ~/Downloads
chmod +x install_nockchain_macos.sh
./install_nockchain_macos.sh
```

脚本将自动完成以下步骤：
- 安装所需依赖（通过 `brew`）
- 安装 Rust
- 拉取 NockChain 项目源码
- 编译项目（大约需要 10~15 分钟）
- 初始化示例 hoon 文件（可选）
- 生成钱包并配置挖矿公钥

---

## 🛠 第二步：设置环境变量（建议）

脚本执行完后会输出如下内容，请**复制粘贴到你的 shell 配置文件中**（根据你使用的 shell 决定）：

对于 `zsh` 用户（macOS 默认）：

```bash
nano ~/.zshrc
```

对于 `bash` 用户：

```bash
nano ~/.bash_profile
```

添加以下三行：

```bash
export PATH="$PATH:$HOME/nockchain/target/release"
export RUST_LOG=info
export MINIMAL_LOG_FORMAT=true
```

保存并关闭后，使配置生效：

```bash
source ~/.zshrc   # 或 source ~/.bash_profile
```

---

## 🔐 第三步：查看生成的钱包

运行脚本后会输出钱包信息（助记词 + 公钥），请**务必保存好这些信息**，其中公钥类似如下格式：

```
0xabc123...789def
```

该公钥已自动写入 Makefile，作为你的挖矿身份标识。

---

## ▶️ 第四步：运行 NockChain 节点

### ✅ 启动 Leader 节点：

```bash
screen -S leader
make run-nockchain-leader
```

### ✅ 启动 Follower 节点：

```bash
screen -S follower
make run-nockchain-follower
```

### 💡 查看日志：

在后台运行时可随时查看日志：

```bash
screen -r leader    # 查看 leader 节点日志
screen -r follower  # 查看 follower 节点日志
```

按下 `Ctrl+A` 然后按 `D` 可以退出 screen 会话而不中断程序。

---

## 🌀 可选：初始化 choo 模块测试

脚本会询问你是否执行一次 `choo` 初始化测试（不是必须步骤），用于测试 hoon 文件构建流程。

若选择执行，它会生成 `hoon/trivial.hoon` 并运行：

```bash
choo --new --arbitrary hoon/trivial.hoon
```

---

## 📄 常见问题

### 1. 报错 "Permission denied"
说明脚本没有执行权限，执行以下命令添加权限：

```bash
chmod +x install_nockchain_macos.sh
```

### 2. 无法找到 `brew`
请先安装 Homebrew：https://brew.sh

---

## 🏁 安装完成！

你已经成功在 macOS 上部署并运行 NockChain 🎉  
后续可根据需要调整 `Makefile` 配置或使用 `screen` 持久化运行。

如有更多问题，可关注推特 https://x.com/qson66698260。

---
