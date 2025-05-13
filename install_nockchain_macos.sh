#!/bin/bash

set -e

# === 基本信息 ===
LOGFILE="install_log_$(date +%F_%H-%M-%S).log"
REPO_URL="https://github.com/zorp-corp/nockchain"
PROJECT_DIR="nockchain"

# === 日志记录 ===
exec > >(tee -a "$LOGFILE") 2>&1

# === 检查 Homebrew ===
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew 未安装，请先访问 https://brew.sh 安装 Homebrew 后再运行本脚本。"
  exit 1
fi

echo -e "\n📦 使用 Homebrew 安装依赖..."
brew update

brew install \
  curl \
  git \
  wget \
  lz4 \
  jq \
  make \
  gcc \
  automake \
  autoconf \
  tmux \
  htop \
  pkg-config \
  openssl \
  leveldb \
  ncdu \
  unzip \
  libtool \
  cmake \
  screen || true

# === 安装 Rust ===
echo -e "\n🦀 安装 Rust（如已安装会自动跳过）..."
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "Rust 已安装，跳过 rustup 安装。"
fi

rustup default stable
source "$HOME/.cargo/env"

# === 拉取仓库 ===
echo -e "\n📁 检查 nockchain 仓库..."
if [ -d "$PROJECT_DIR" ]; then
  echo "⚠️ 检测到已有 $PROJECT_DIR 目录，是否删除并重新拉取？(y/n)"
  read -r confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    rm -rf "$PROJECT_DIR"
    git clone "$REPO_URL"
  else
    echo "➡️ 使用已有目录 $PROJECT_DIR"
  fi
else
  git clone "$REPO_URL"
fi

cd "$PROJECT_DIR"

# === 编译 nockchain ===
if [ -f Makefile ]; then
  cp Makefile Makefile.bak
fi

echo -e "\n🔧 编译中（大约 15 分钟）..."
make install-choo
make build-hoon-all
make build

# === 环境变量配置提示 ===
echo -e "\n✅ 编译完成，你可以将以下内容添加到 ~/.zshrc 或 ~/.bash_profile："
echo "export PATH=\"\$PATH:$PWD/target/release\""
echo "export RUST_LOG=info"
echo "export MINIMAL_LOG_FORMAT=true"

export PATH="$PATH:$PWD/target/release"
export RUST_LOG=info
export MINIMAL_LOG_FORMAT=true

# === 可选初始化 choo 模块 ===
read -p $'\n🌀 是否执行 choo 初始化测试？输入 y 继续（非必须）：' confirm_choo
if [[ "$confirm_choo" == "y" || "$confirm_choo" == "Y" ]]; then
  mkdir -p hoon assets
  echo "%trivial" > hoon/trivial.hoon
  choo --new --arbitrary hoon/trivial.hoon
fi

# === 钱包生成 ===
echo -e "\n🔐 生成钱包（请复制并妥善保存助记词和公钥）"

wallet_output=""
if [ -f "./target/release/wallet" ]; then
  wallet_output=$(./target/release/wallet keygen)
elif [ -f "./target/release/nock-wallet" ]; then
  wallet_output=$(./target/release/nock-wallet keygen)
else
  echo "❌ 未找到 wallet 可执行文件，请检查构建。"
fi

if [[ -n "$wallet_output" ]]; then
  echo -e "\n📜 钱包信息如下（请妥善保存）："
  echo "$wallet_output"

  pubkey=$(echo "$wallet_output" | grep -Eo '0x[a-fA-F0-9]{40}')
  if [[ -n "$pubkey" ]]; then
    echo -e "\n✅ 自动提取到公钥：$pubkey"
    sed -i.bak "s|^export MINING_PUBKEY :=.*$|export MINING_PUBKEY := $pubkey|" Makefile
  else
    echo -e "\n⚠️ 未能自动提取公钥，请手动输入："
    read -p "请输入你的挖矿公钥: " new_pubkey
    sed -i.bak "s|^export MINING_PUBKEY :=.*$|export MINING_PUBKEY := $new_pubkey|" Makefile
  fi
fi

# === 运行提示 ===
echo -e "\n🧠 配置完成，你可以使用以下命令运行 leader 和 follower 节点："

echo -e "\n➡️ 启动 leader 节点："
echo -e "screen -S leader\nmake run-nockchain-leader"

echo -e "\n➡️ 启动 follower 节点："
echo -e "screen -S follower\nmake run-nockchain-follower"

echo -e "\n📄 查看日志："
echo -e "screen -r leader   # 查看 leader 节点日志"
echo -e "screen -r follower # 查看 follower 节点日志"
echo -e "按 Ctrl+A 再按 D 可退出 screen 会话不关闭程序"

echo -e "\n📦 日志已保存至：$LOGFILE"
echo -e "\n🎉 安装完成，祝你愉快！"
