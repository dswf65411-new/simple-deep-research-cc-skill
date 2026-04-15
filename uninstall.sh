#!/usr/bin/env bash
# /research skill 移除
set -e
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
echo "移除 $CLAUDE_DIR/commands/research.md"
rm -f "$CLAUDE_DIR/commands/research.md"
echo "移除 $CLAUDE_DIR/research-phases/（整個目錄）"
rm -rf "$CLAUDE_DIR/research-phases"
echo "✅ 已完全移除"
