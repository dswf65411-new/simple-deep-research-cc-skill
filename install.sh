#!/usr/bin/env bash
# /research skill 一鍵安裝
# 用法：./install.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
COMMANDS_DIR="$CLAUDE_DIR/commands"
PHASES_DIR="$CLAUDE_DIR/research-phases"

echo "===== /research skill 安裝 ====="
echo "目標位置：$CLAUDE_DIR"
echo

# 建目錄
mkdir -p "$COMMANDS_DIR"
mkdir -p "$PHASES_DIR"

# 入口 slash command
if [ -f "$COMMANDS_DIR/research.md" ]; then
  echo "⚠️  $COMMANDS_DIR/research.md 已存在，備份為 research.md.bak.$(date +%s)"
  mv "$COMMANDS_DIR/research.md" "$COMMANDS_DIR/research.md.bak.$(date +%s)"
fi
cp "$SCRIPT_DIR/research.md" "$COMMANDS_DIR/research.md"
echo "✅ 已安裝：$COMMANDS_DIR/research.md"

# Phase 指令檔
for f in "$SCRIPT_DIR/research-phases"/*.md; do
  base=$(basename "$f")
  cp "$f" "$PHASES_DIR/$base"
done
echo "✅ 已安裝：$PHASES_DIR/（11 個檔案）"

echo
echo "===== 安裝完成 ====="
echo
echo "下一步："
echo "  1. 開一個新 Claude Code session"
echo "  2. 輸入 /research 你的研究主題"
echo
echo "範例："
echo "  /research 2025 台灣電動車市占率"
echo "  /research --quick 特斯拉 Q3 財報重點"
echo
echo "選用 CLI 工具（增強驗證階段）："
echo "  pip3 install bespokelabs-minicheck minicheck-cli   # Grounding CLI"
echo "  詳見：$PHASES_DIR/ref-cli-tools.md"
echo
