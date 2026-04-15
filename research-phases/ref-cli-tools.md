# 本地驗證工具 CLI 參考

所有驗證工具已從 MCP 轉為 CLI 模式。統一透過 Bash tool 呼叫，輸入 JSON 至 stdin，輸出 JSON 至 stdout。

## Python 路徑
```
PY=/Users/yao.chu/.pyenv/versions/3.13.12/bin/python3
MC=/Users/yao.chu/.claude/mcp-servers
MINICHECK_PY=/Users/yao.chu/.claude/mcp-servers/minicheck-env/bin/python3.11
```

---

## 1. Bedrock Grounding Check（主要驗證）

```bash
echo '{"claims":["claim1","claim2"],"sources":["source text"]}' | $PY $MC/bedrock-guardrails.py --cli
```

可選參數：`guardrail_id`（預設 981o7pz3ze8q）、`threshold`（預設 0.7）、`region`（預設 us-east-1）

輸出：`summary.grounding_rate` + 每個 claim 的 `grounding_score` 和 `verdict`（GROUNDED / NOT_GROUNDED）

---

## 2. MiniCheck（備用驗證）

```bash
echo '{"claims":["claim1"],"sources":["source text"]}' | $MINICHECK_PY $MC/minicheck.py --cli
```

注意：首次呼叫需載入模型 ~30 秒，後續 ~1 秒/claim。

輸出：`summary.support_rate` + 每個 claim 的 `confidence` 和 `supported`（true/false）

---

## 3. NeMo Grounding Check（第三備用）

```bash
echo '{"claims":["claim1"],"sources":["source text"],"threshold":0.7}' | $PY $MC/nemo-guardrails.py --cli
```

輸出：`summary.grounding_rate` + 每個 claim 的 `grounding_score` 和 `verdict`

---

## 4. URL Health Check

```bash
echo '{"urls":["https://example.com"],"timeout":15}' | $PY $MC/urlhealth.py --cli
```

輸出：每個 URL 的 `status`（LIVE / STALE / LIKELY_HALLUCINATED / UNKNOWN）

---

## 5. Citations API（引用精確度）

```bash
echo '{"tool":"citations_from_text","documents":[{"title":"doc1","content":"..."}],"question":"..."}' | ANTHROPIC_API_KEY="$KEY" node $MC/citations-api.mjs --cli
```

支援三種 tool：`citations_from_text`、`citations_from_file`、`citations_from_pdf`

輸出：帶引用標記的回答文字

---

## Grounding 工具可用性檢查

Phase 1b 開始前必須執行：

```bash
# 測試 Bedrock
echo '{"claims":["The sky is blue."],"sources":["The sky is blue during a clear day."]}' | $PY $MC/bedrock-guardrails.py --cli 2>/dev/null

# 若失敗，測試 MiniCheck
echo '{"claims":["The sky is blue."],"sources":["The sky is blue during a clear day."]}' | $MINICHECK_PY $MC/minicheck.py --cli 2>/dev/null

# 若也失敗，測試 Nemo
echo '{"claims":["The sky is blue."],"sources":["The sky is blue during a clear day."]}' | $PY $MC/nemo-guardrails.py --cli 2>/dev/null
```

三者全部失敗 → 停止研究，報錯 `[GROUNDING-UNAVAILABLE]`。
