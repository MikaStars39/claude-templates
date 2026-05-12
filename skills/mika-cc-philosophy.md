---
name: mika-cc-philosophy
description: "cc-native repo 设计哲学 — CLAUDE.md/docs/tests 三大块的角色、docs 四子目录（arch/experience/roadmap/reference）的分工、什么内容放哪里、什么不该写。TRIGGER when: 用户问 cc-native 是什么、问某类 doc 该写什么 / 不该写什么、第一次在新 repo 用 mika-* skill、或在执行 docs-related skill 时不确定背后的设计意图。其他 mika-* docs skill 在执行前应先 Read 此文件以理解设计哲学。"
user_invocable: true
---

# cc-native 设计哲学

这份文档解释 cc-native repo 怎么组织、为什么这么组织。其他 mika-* skill（cc-init / create-arch / create-experience / add-roadmap / save-reference / doc-gardening / doc-updating / cc-native-audit）在执行前都应该先读这一份，否则做出来的 doc 容易偏离设计意图。

## 第一性原理

**Claude 的 context window 填得越满表现越差。** 所以 cc-native repo 设计的目标只有一个：让 CC 在做事的时候少读没用的东西。

这是判断所有设计决策的标准。新增任何文档前先问："这能让 CC 下次少读多少？"如果答案是"几乎为零"，那就不该写。

## 三大块

| 位置 | 角色 | 进入条件 |
|------|------|----------|
| `CLAUDE.md` | 每轮对话预置进 system prompt 的最小集合 | 每次对话都用得上的（仓库一句话介绍、目录结构、用户硬约束） |
| `docs/` | CC 接任务时 grep 的索引层 | 不每次都用，但用到时能省读源码的精力 |
| `tests/` | CC 自己跑确认对错 | lint/test/build，不用人当反馈源 |

源码（`src/` 或别的）不算这三大块——它是被 docs 索引的目标。

## docs/ 顶层两份指路文档

放在所有子目录之外，因为 CC 几乎每次动手都该过一眼：

- `docs/GIT.md` — 本仓库的分支、commit、PR 规范
- `docs/SECURITY.md` — CC 不能做的事（API key 不准进代码、哪些文件不准读）

## docs/ 四个子目录的分工

每个子目录回答一个不同的问题。**写文档时第一件事是判断它该进哪个子目录**——选错地方就等于放在了 CC 不会去找的位置。

### arch/ — "这块代码为什么这么设计？"

- **写**：设计意图、tradeoff、跨模块约束
- **不写**：函数签名、字段列表、逐行复述（这些代码本身就有）
- **触发**：CC 接任务、准备动某块代码之前先扫一眼
- **演化**：跟代码一起长期演化，代码改了 arch 也得跟

### experience/ — "上次撞到 X 是怎么回事？"

- **写**：症状 → 根因 → 解法（三段式，强制）
- **不写**：通用规则、跟具体事件无关的总结
- **触发**：CC 看到某个错误信息或奇怪现象时去查
- **演化**：只增不删，按事件归档。如果某条经验抽象成了项目通用规则，**升级**到 arch 或 CLAUDE.md，从 experience 里毕业

### roadmap/ — "这事还没做但想过怎么做？"

- **写**：想做但暂不打算做的方案，**强制带阻塞理由**（"等 v2 schema 落地后再做"）
- **不写**：愿望清单（没有阻塞理由就不要进）
- **触发**：CC 接到新任务时先看，避免重复设计
- **演化**：阻塞解除就开始做、做完就删

### reference/ — "外部资料里学到了什么？"

- **写**：别的 repo 的关键信息、paper 笔记、外部 API 文档摘要
- **不写**：原文整段复制（提炼成 TL;DR + 关键点）
- **触发**：CC 要避免再去 webfetch / 查一遍
- **演化**：外部资料改了就更新，过时就删

## 索引规则

- 每个子目录一个 `README.md` 列出索引
- `docs/` 根目录一个 `README.md` 介绍这四个子目录分别在干什么
- 子目录之间的文档可以互相引用（一件事相关材料能串起来）
- **不更新 README 索引等于没写**——CC 找不到

## 维护是设计的一部分

上面这套只在文档不漂移的时候才成立。docs 引用的代码路径会过期、子目录 README 索引会跟实际文件对不上、CLAUDE.md 项目地图会跟着代码漂。所以 cc-native repo 一开始就得规划维护：

- `/mika-doc-gardening` — 修代码锚点漂移
- `/mika-doc-updating` — 同步目录 README
- `/mika-cc-native-audit` — 审整体结构健康

## 写文档时的判断流程

接到"写一份 X 文档"的任务，按这个顺序判断：

1. **它属于哪个子目录？**（看上面四个子目录的"写 / 不写"清单；选错位置等于没写）
2. **是不是已经有同类的？**（先 ls + grep 一遍，避免重复或冲突）
3. **写完后能让 CC 下次少读多少？**（如果答案是"几乎为零"，说明根本不该写）
4. **更新对应的 README 索引**（不更新等于没写）

跑顺这套流程，CC 在你的 repo 里干活的体感会和 vibecoding 完全不同——它每次接任务都从已经整理好的 docs 切入，而不是从一堆代码里盲目 grep。
