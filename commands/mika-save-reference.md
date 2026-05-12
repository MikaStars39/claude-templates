
# Save Reference — Capture External Knowledge

> **背景**：如果还不熟悉 cc-native 的设计哲学（每类 doc 该写什么 / 不该写什么、为什么），先 Read `~/.claude/skills/mika-cc-philosophy.md` 再继续。

把外部资料整理成结构化笔记存进 `docs/reference/`，下次 CC 不用再 webfetch。

## When to Use

- 读完一篇 paper / 博客 / API 文档觉得以后要用
- 调研别的 repo 之后想存关键结论
- 用户说"把这个存下来" / "记一下这个 paper"

## Procedure

### 1. 拿到源

参数解析：`/mika-save-reference <url|path|题目>`

- 如果是 URL：用 `WebFetch` 拉
- 如果是本地文件路径：用 `Read`
- 如果是题目（"那个讲 prompt caching 的文章"）：先问用户给个具体来源（URL / 路径 / 粘贴正文）

如果对话里已经有相关内容（比如你刚读过），直接用对话里的，不要重复 fetch。

### 2. 提炼

读完之后写三块：

- **TL;DR**（2-4 句）：最核心的结论。一个不读全文的人看完应该知道这资料"在讲什么 + 主要结论是什么"
- **关键点**（3-8 条）：可执行级别的事实 / 数字 / 方法。例："prompt cache TTL 是 5 分钟"、"超过 1024 token 才会 cache"
- **什么时候用得上**：在我们这个 repo 的什么场景下需要回来翻这份笔记。这条最关键，没有它笔记就是死的

### 3. 命名

`<source-or-topic-slug>.md`，全小写连字符。看名字能猜出主题：

- `claude-api-prompt-caching.md`
- `transformers-flash-attention-paper.md`
- `nginx-rate-limit-cookbook.md`

不要用作者名 / 日期当主键（按主题搜更频繁）。

### 4. 查重

`ls docs/reference/` 看一下。同主题已有就问用户："`<existing>.md` 是相关主题，要追加 / 新建 / 取消？"

### 5. 写文件

模板：

```markdown
# <一句话标题>

来源：<URL 或 完整引用>

## TL;DR

<2-4 句>

## 关键点

- <可执行级别的事实 1>
- <可执行级别的事实 2>
- ...

## 什么时候用得上

<在本 repo 里什么场景下回来翻这份>

## 相关

<可选：链接到 docs/arch/ 或同类 reference>
```

不复制原文长段落——那样跟直接 fetch 没区别还更慢。提炼是这个 skill 的全部价值。

### 6. 更新索引

`docs/reference/README.md` 加一行：

```
- [<slug>](<slug>.md) — <一句话来源 + 主题>
```

README.md 不存在就先用最简结构创建（参考 `/mika-cc-init` 生成的模板）。

### 7. 报告

告诉用户文件路径 + 一句话内容摘要。

## What This Skill Does NOT Do

- 不存大段原文——提炼才是价值，复述不是
- 不替代 webfetch——这个 skill 是把 webfetch 的结果**沉淀**下来，不是替代它
- 不区分稳定 / 易腐资料——目前 reference/ 不分子目录。如果 repo 里这种笔记多到需要分（比如 stable/ 和 sibling-repos/），让用户决定怎么拆
