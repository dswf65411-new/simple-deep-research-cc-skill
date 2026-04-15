---
description: "正反方辯證研究（v5.0）。Workspace 檔案傳遞 + 結構化溯源鏈 + 條件式辯證 + Gate Check。Phase 0 規劃 → Phase 1a 搜尋 → Phase 1b 驗證 → Phase 2 整合 → Phase 3 報告。Trigger on: '/research', '研究', '調查', '幫我查', '幫我研究'."
argument-hint: "<研究主題或問題> [--quick | --standard]"
---

# 深度研究 Orchestrator v5.0

## 鐵律（4 條，違反任何一條 = 研究失敗）

1. **Sub agent 禁止呼叫 MCP。** 搜尋和驗證由主 Agent 執行。Sub agent 只能讀本地檔案 + 文本比對。
2. **原文先行，禁止模型記憶。** 所有事實必須來自 web search 全文（WebFetch / Serper scrape），不得僅依賴搜尋摘要。每個論點：先逐字引用（附 URL），再標記為 Claude 推論的分析。無原文引用的事實陳述禁止出現在報告中。
3. **數字溯源。** 報告中的數字分三類：
   - `ORIGINAL`：與來源原文完全一致，不得四捨五入或「大約」化。
   - `NORMALIZED`：僅限單位/貨幣換算，必須附註 `(orig: {原文數字+單位})`。
   - `DERIVED`：計算結果，必須標記 [DERIVED] 並列出公式、來源 claim_id。
   - 無標記的數字禁止出現在報告中。
4. **溯源鏈完整。** 報告中每句事實 → 對應 claim_id → 對應 quote_id/number_id → 對應 source_id。鏈斷裂的句子直接刪除。

## Fail-Fast 原則

自動回補（補搜、重驗）最多 2 次。第 3 次仍失敗 → 標記為 [BLOCKER]，在報告中如實呈現，不再迴圈。

## Workspace

研究開始時建立 workspace：

```
~/Downloads/research-workspace/{YYYY-MM-DD}_{主題簡稱}/
├── phase0-plan.md              # Phase 0 輸出（含結構化 header）
├── coverage.chk                # 覆蓋追蹤（簡易 checklist 格式）
├── source-registry.md          # 來源登記表（Phase 1a 建立）
├── claim-ledger.md             # Claim 溯源帳本（Phase 1b 建立）
├── search-results/             # 每來源一檔
│   └── Q{n}/S{id}.md
├── grounding-results/
│   └── q{n}_grounding.md
├── report-sections/
│   └── q{n}_section.md
├── gap-log.md                  # 缺口日誌（取代 coverage-matrix 的複雜 table）
├── statement-ledger.md         # 報告句級溯源（Phase 3 建立）
├── execution-log.md            # 執行日誌
└── final-report.md             # 最終報告
```

## 研究深度

| 模式 | 標記 | 子問題數 | 迭代上限 | 搜尋預算 |
|------|------|---------|---------|---------|
| Quick | `--quick` | 1-2 | 1 輪 | 30 次 |
| Standard | `--standard` | 2-5 | 2 輪 | 60 次 |
| **Deep** | （預設） | 5-10 | 5 輪 | 150 次 |

## 參數

使用者輸入: `$ARGUMENTS`
若為空 → 用 AskUserQuestion 詢問研究主題。

## Task Scaffolding Contract（重要：全程貫徹）

**核心原則：同時只有一個 leaf-level task 是 `in_progress`。LLM 專注當下任務，不同時顧及其他。**

### Task 階層（四層）

| Level | 範圍 | 命名前綴 | 建立時機 |
|-------|------|---------|---------|
| 1 | 整個研究 | `[RESEARCH] <主題>` | 研究啟動時一次 |
| 2 | Phase | `[P0]` / `[P1a]` / `[P1b]` / `[P2]` / `[P3]` | 研究啟動時一次建齊 5 個 |
| 3 | Step | `[P{n}/S{m}] <step 名稱>` | 進入該 phase 時一次建齊該 phase 全部 step |
| 4 | 延伸子任務 | `[P{n}/S{m}/sub] <子任務>` | 該 step 執行中動態建立（如每個 query、每個 source、每個 claim 驗證） |

### 執行契約（必須遵守）

1. **研究啟動時**（讀完使用者主題或澄清完後第一個動作）：
   - 建 **1 個** Level 1 task：`[RESEARCH] <主題>`
   - 建 **5 個** Level 2 tasks：`[P0] Clarify + Plan`、`[P1a] Search`、`[P1b] Verify`、`[P2] Integrate`、`[P3] Report`
   - 把 Level 1 設為 `in_progress`

2. **進入每個 Phase 時**：
   - 把對應 Level 2 task 設 `in_progress`
   - Read 該 phase 指令檔
   - **先一次建齊該 phase 全部 Level 3 step tasks**（該 phase 檔案頂部有明確 Entry Task List）
   - 不要邊做邊建 step task

3. **執行每個 Step**：
   - 把該 Level 3 task 設 `in_progress`
   - Read 該 step 對應的指令內容（該 phase 檔裡的 `## Step N` 段落）
   - 若 step 會延伸具體子工作（如搜 10 個 query、深讀 15 個 URL、驗證 50 個 claim）→ 為每個子工作建一個 Level 4 task，逐個 `in_progress` → 做 → `completed`
   - Step 主 task 等所有 Level 4 子任務都 completed 後才 completed

4. **Phase 完成時**：
   - 跑該 phase 的 Gate Check（指令檔末尾）
   - 全過才把 Level 2 task 設 completed
   - 進下一個 Phase

5. **研究全部完成時**：
   - 把 Level 1 task 設 completed
   - 呈現 final report

### 禁止事項

- **禁止跳 level**：不能沒建 Level 2 就開始做 step
- **禁止多重 in_progress**：Level 3/4 同時只能有 1 個 in_progress
- **禁止邊做邊建 step task**：進 phase 的第一個動作是一次建齊 step tasks
- **禁止提前建 Level 4**：Level 4 子任務在進該 step 時才動態建，避免過早展開
- **禁止跳過 Gate Check**：Gate 沒過不能 completed 對應 Level 2 task

### 為什麼這樣做

LLM 在 context 裡同時看到多個並列任務時，注意力會稀釋，容易跳步或遺漏細節。把當下工作壓縮到「只有一個 in_progress leaf task + 該 step 的內容」，LLM 的思考空間全部聚焦。階層結構讓宏觀進度可見（Level 1/2）但不干擾當下執行（Level 3/4）。

---

## 流程

**每個 Phase 開始前，用 Read 讀取對應指令檔。Phase 間只透過 workspace 檔案傳遞資料。**
**每個 Phase 結束時，必須通過該 Phase 的 Gate Check（列在指令檔末尾），缺一不可。**

### Phase 0 → `~/.claude/research-phases/phase0-clarify.md`
澄清 → 規劃 → 寫入 `workspace/phase0-plan.md` + `workspace/coverage.chk` → 等使用者確認

### Phase 1a → `~/.claude/research-phases/phase1a-search.md`
搜尋 → 深讀（WebFetch → Serper scrape → 標記 UNREACHABLE）→ 逐字抄錄 → 寫入 workspace

### Phase 1b → `~/.claude/research-phases/phase1b-verify.md`
**1b-A：** Grounding + 4 維品質 → 全過就進 Phase 2
**1b-B（僅 1b-A 未過時觸發）：** Subagent 核對 + 辯證 + 補搜 → 迭代

### Phase 2 → `~/.claude/research-phases/phase2-integrate.md`
從 approved claims 整合 → 矛盾裁決 → 逐段寫入 `workspace/report-sections/`

### Phase 3 → `~/.claude/research-phases/phase3-report.md`
合併段落 → statement-ledger → Subagent 最終核對 → **核對通過後**才寫摘要/圖表 → 寫入 `workspace/final-report.md`

### 任何 Phase 卡住 → `~/.claude/research-phases/fallback.md`

## 來源評估標準

讀取 `~/.claude/research-phases/source-criteria.md`（T1-T6 六級）。

## 回應語言

繁體中文。技術術語保留原文。
