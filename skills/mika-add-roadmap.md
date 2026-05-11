---
name: mika-add-roadmap
description: "Capture an idea into docs/roadmap/<slug>.md as deferred design intent (motivation, sketch, blocker). Use when something comes up in conversation worth tracking but not doing now. Helps CC pick up half-formed plans when working on related future tasks."
user_invocable: true
---

# Add Roadmap — Capture Deferred Intent

聊出一个想法但不打算现在做，用这个 skill 存进 `docs/roadmap/`。后面 CC 接到相关新任务时会先看这里，避免推翻已有的半成型方案。

## When to Use

- 聊到一个有趣的想法但当前不做
- 看到一个明显该改但优先级不够的事
- 用户说"先记一下" / "存进 roadmap" / "以后再做"

## Procedure

### 1. 拿到要点

参数解析：`/mika-add-roadmap <一句话想法>`

如果用户没给参数或太短，用 `AskUserQuestion` 收齐三件事：

- **动机**：为什么想做？解决什么问题？
- **草图**：脑子里大概的方案是什么样的（可以很粗）
- **阻塞**：现在为什么不做？（依赖什么？时间不够？等谁？）

阻塞这一项最关键——没有它 roadmap 会无差别堆积。如果用户没有阻塞理由，直接问："这个为什么不现在做？"

### 2. 命名

`<short-slug>.md`，看名字能猜出主题：

- `add-streaming-mode.md`
- `migrate-to-redis-cluster.md`
- `unify-config-schema.md`

不要前缀编号或日期。优先级和顺序在 README 索引里体现，不在文件名里。

### 3. 查重

`ls docs/roadmap/` 看一下。同主题已有就问用户："`<existing>.md` 是相关想法，要追加 / 新建 / 取消？"

### 4. 写文件

模板：

```markdown
# <一句话标题>

## 动机

<为什么想做。解决什么问题、改善什么>

## 草图

<脑子里的方案。可以很粗，但要让以后接手的 CC 能 grep 到关键词>

## 阻塞

<为什么现在不做。依赖什么、等什么>

## 相关

<可选：链接到 docs/arch/ 里相关模块、或同类 roadmap 条目>
```

不写"预计工时""负责人"——这是 design backlog 不是 task tracker。

### 5. 更新索引

`docs/roadmap/README.md` 加一行：

```
- [<slug>](<slug>.md) — <一句话动机>
```

README.md 不存在就先用最简结构创建（参考 `/mika-cc-init` 模板）。

### 6. 报告

告诉用户文件路径 + 一句话回顾。

## What This Skill Does NOT Do

- 不当 task tracker——没有 deadline、assignee、priority 字段
- 不替代 CLAUDE.md 里的 user constraints——roadmap 是"想做的事"，约束是"必须遵守的规则"
- 不写完整设计文档——只是 sketch，详细设计等真要做的时候再写
