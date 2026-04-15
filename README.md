# /research — 深度研究 Orchestrator v5.0

給 [Claude Code](https://claude.com/claude-code) 使用的深度研究 slash command。

Repo：<https://github.com/dswf65411-new/simple-deep-research-cc-skill>

## 特色

- **4 條鐵律**：Sub agent 禁用 MCP／原文先行／數字溯源／溯源鏈完整
- **5 Phase 流程**：Clarify → Search → Verify → Integrate → Report
- **結構化溯源**：每句事實 → claim_id → quote_id/number_id → source_id
- **Task scaffolding**：四層 task 階層，同時只一個 leaf in-progress
- **自動 fail-fast**：補搜/重驗最多 2 次，第 3 次標 [BLOCKER]
- **三種深度模式**：`--quick`（30 次搜尋）／`--standard`（60 次）／預設 Deep（150 次）

## 安裝

**方式 A（git clone，推薦）：**

```bash
git clone https://github.com/dswf65411-new/simple-deep-research-cc-skill.git
cd simple-deep-research-cc-skill
./install.sh
```

**方式 B（下載 zip）：** 按 GitHub 右上角綠色 `Code` → `Download ZIP`，解壓後 `./install.sh`。

**方式 C（curl 單指令）：**

```bash
curl -sL https://github.com/dswf65411-new/simple-deep-research-cc-skill/archive/refs/heads/main.tar.gz | tar -xz \
  && cd simple-deep-research-cc-skill-main \
  && ./install.sh
```

會安裝到：
- `~/.claude/commands/research.md` — slash command 入口
- `~/.claude/research-phases/` — Phase 指令檔與 reference

若 `~/.claude/commands/research.md` 已存在，install.sh 會自動備份為 `research.md.bak.<timestamp>`。

## 使用

開新 Claude Code session，輸入：

```
/research 你的研究主題
/research --quick  快速模式（1-2 子問題，1 輪迭代）
/research --standard  標準模式（2-5 子問題，2 輪迭代）
/research 主題  深度模式（5-10 子問題，5 輪迭代，預設）
```

範例：
```
/research 2025 台灣電動車市占率
/research --quick 特斯拉 Q3 財報重點
/research 全球 GPU 短缺對 AI 新創的影響
```

## Workspace

每次研究在 `~/Downloads/research-workspace/{YYYY-MM-DD}_{主題}/` 產出：

```
├── phase0-plan.md         # 規劃
├── coverage.chk           # 覆蓋追蹤
├── source-registry.md     # 來源登記
├── claim-ledger.md        # 溯源帳本
├── search-results/        # 每來源一檔
├── grounding-results/     # Grounding 結果
├── report-sections/       # 逐段草稿
├── statement-ledger.md    # 句級溯源
├── gap-log.md             # 缺口
└── final-report.md        # ← 最終交付
```

## 選用 CLI 工具（提升驗證品質）

Phase 1b Grounding 會用到（沒裝也能跑，只是少一些自動核對）：

```bash
pip3 install bespokelabs-minicheck minicheck-cli
```

詳見：`~/.claude/research-phases/ref-cli-tools.md`

## 結構

```
research-skill-package/
├── README.md                         # 這份說明
├── install.sh                        # 一鍵安裝
├── uninstall.sh                      # 移除
├── research.md                       # → ~/.claude/commands/research.md
└── research-phases/                  # → ~/.claude/research-phases/
    ├── phase0-clarify.md             # Phase 0 澄清 + 規劃
    ├── phase1a-search.md             # Phase 1a 搜尋 + 深讀
    ├── phase1b-verify.md             # Phase 1b Grounding + 辯證
    ├── phase2-integrate.md           # Phase 2 整合
    ├── phase3-report.md              # Phase 3 報告產出
    ├── fallback.md                   # 任何 Phase 卡住 fallback
    ├── source-criteria.md            # T1-T6 六級來源評估
    ├── ref-challenge-checklist.md    # 22 項挑戰 checklist
    ├── ref-citation-embedding.md     # 引用嵌入規則
    ├── ref-cli-tools.md              # Grounding CLI 用法
    └── ref-multilingual.md           # 多語搜尋策略
```

## 移除

```bash
./uninstall.sh
```

## 授權

MIT — 隨意使用、修改、分享。
