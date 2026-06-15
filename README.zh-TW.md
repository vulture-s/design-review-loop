# design-review-loop

一個可重用的 **Claude Code skill**，把視覺／設計工作交給 web 沙箱裡的設計 agent
（例如 claude.ai 上的 Claude，「Claude Design」），再把成果帶回你的 repo —— 不用每次
都在同樣可避免的坑上浪費一輪來回。

> 🌐 [English](README.md) | **繁體中文**

## 這解決什麼問題

CLI 編碼 agent 能 grep、跨檔重構、讀整個 repo —— 但**做不了視覺判斷**（沒有眼睛）。
需要 mock screens、視覺 audit、layout／UX 決策時，你把工作交給一個**有視覺能力但跑在
沙箱裡**的設計 agent：

- 它**讀不到你的本機磁碟** —— 給它檔案路徑沒用
- 它**拒收 `.zip`**，只吃**扁平**的上傳檔案清單
- 它產出的東西在你下載回來之前，只活在**它的沙箱裡**

每個團隊臨時做這套來回，都會浪費一輪重新踩這三個事實。這個 skill 把它們內化：一支把
brief + 截圖**攤平到桌面**供拖曳上傳的 staging script、一份固定的**deliverable
contract**（讓設計 agent 知道「完成」的定義），以及一個**ingest** 步驟（讓成果以可預期
的結構落回 repo）。

## 5 階段來回

```
1 OUTBOUND   收集現況 + 證據 → 把扁平檔案攤上桌面供上傳
2 DESIGN     你上傳 → 設計 agent 做 audit + rebuild → 回交 deliverable
3 RETURN     下載 → 把設計 SSOT 版控 → design↔backend↔frontend 三層對帳 → 驗收
4 DISPATCH   按嚴重度排序 → critical fix 先交給實作者
5 CLOSEOUT   部署後對 ground truth 驗證 → 記錄
```

完整流程見 [`SKILL.md`](./SKILL.md)。

## 安裝

把整個資料夾丟進你的 Claude Code skills 目錄：

```bash
cp -r design-review-loop ~/.claude/skills/
# 或放進某個專案：cp -r design-review-loop <project>/.claude/skills/
```

Claude Code 會從 `SKILL.md` 的 `name` + `description` frontmatter 認出它。

## 直接用 staging script

```bash
bash design-review-loop/stage-handover.sh <source-dir> [dest-name] [--zip] [--dry-run]
```

遞迴收集 `<source-dir>` 底下每個 web 可接受的檔案，攤平到 `~/Desktop/<dest-name>/`，
把所有 `.md` 縫成單一 `00-READ-FIRST-bundle.md`，並（加 `--zip`）另寫一個 zip 供傳輸／備份。

> **上傳散檔，不要上傳 zip** —— web 沙箱拒收壓縮檔，只讀扁平清單。

## 內容物

| 檔案 | 用途 |
|---|---|
| `SKILL.md` | 5 階段工作流 |
| `stage-handover.sh` | 把 brief + 截圖攤平到桌面供上傳 |
| `references/deliverable-contract.md` | 設計 agent 必須回交什麼（定義 ⟶ 驗收） |
| `references/return-package-structure.md` | 回交成果落地的結構 |
| `references/web-sandbox-limits.md` | 為何路徑／zip 不行；可接受的格式 |
| `references/design-build-reconcile.md` | Stage 3 對帳：設計 SSOT 版控、design↔backend↔frontend 矩陣、build-target lock |
| `templates/handover-package.template.md` | 你交付的 master brief |

## 測試

```bash
bash test/smoke.sh
```

攤平一個 fixture 並驗證 contract（攤平、丟掉被拒格式、縫 bundle、`--dry-run` 不寫任何檔）。
每次 push 在 CI 跑 —— 見 [`.github/workflows/ci.yml`](./.github/workflows/ci.yml)。

## 授權

MIT —— 見 [`LICENSE`](./LICENSE)。
