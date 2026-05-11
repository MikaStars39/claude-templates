---
name: mika-create-experience
description: "Capture a just-solved problem from the current conversation as a docs/experience/<slug>.md (symptom → root cause → fix). Use right after fixing a bug, debugging an environment issue, or learning a non-obvious gotcha."
user_invocable: true
---

# Create Experience — Capture What Was Just Learned

把对话里刚解决的问题提炼成一份 experience 文档归档进 `docs/experience/`，方便后面 CC 看到同样症状时能直接定位。

## When to Use

- 刚 debug 完一个非显然的 bug
- 刚解决了一个环境配置问题（B300 上 GLIBC 不兼容、某个 CUDA 版本挂等）
- 学到一个项目特定的坑
- 用户说"记一下" / "存进 experience" / "把这个写下来"

## Procedure

### 1. 确认有素材

如果当前对话里没有刚解决的具体问题，用 `AskUserQuestion` 问用户想记哪个问题。不要凭空编造。

### 2. 提炼三段

- **症状**：用户最初看到的错误信息、奇怪现象、卡住的状态。具体到能 grep 到的程度（错误码、关键日志行、命令输出）。
- **根因**：真正的原因。不是"试了 X 就好了"，而是"为什么 X 能解决"。
- **解法**：具体步骤。有命令贴命令，有配置贴配置。

任何一段缺就直接问用户补全，不要想象填。

### 3. 命名

文件名 `<short-descriptive-slug>.md`，全小写，连字符。看名字能猜出是什么问题：

- `b300-pip-install-glibc.md`
- `multiprocessing-vs-threading.md`
- `redis-session-token-leak.md`

避免日期前缀（按事件命名比按日期更易搜）。用户明确要时间戳就尊重。

### 4. 查重

`ls docs/experience/` 看一下。如果有同名或高度相似的文档，问用户："`<existing>.md` 看起来涵盖了这个，要追加还是新建？"

### 5. 写文件

模板：

```markdown
# <一句话标题>

## 症状

<具体表现：错误信息、命令输出、堆栈关键行>

## 根因

<为什么会这样。解释机制，不只描述事实>

## 解法

<具体步骤 / 命令 / 配置变更。可执行级别>

## 相关

<可选：链接到 docs/arch/ 或 docs/reference/ 里的相关文档；或同类 experience>
```

不加"作者""时间"——git 已经记了。

### 6. 更新索引

读 `docs/experience/README.md`，在合适位置（按主题或时间倒序，跟现有风格一致）加一行：

```
- [<slug>](<slug>.md) — <一句话什么问题>
```

README.md 不存在就先用最简结构创建：

```markdown
# Experience

记录踩过的坑。每条文档：症状 → 根因 → 解法。

## 索引

- [<slug>](<slug>.md) — <一句话什么问题>
```

### 7. 报告

告诉用户创建了什么文件、更新了哪个 README、内容是否需要补充。

## What This Skill Does NOT Do

- 不写通用经验——通用规则应该升级到 `docs/arch/` 或 `CLAUDE.md`
- 不复述代码——experience 写"事件 + 教训"，不是"代码怎么实现的"
- 不替代 git commit message——commit 写做了什么，experience 写为什么这么做
