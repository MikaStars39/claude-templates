# Claude Code Done Right

这个仓库尝试总结一些我自己觉得如何组织Claude Code高效完成工作的经验，套用GSD的一句话：

> Vibecoding 的名声不算好。你描述需求，AI 生成代码，结果往往是质量不稳定、规模一上来就散架的垃圾。它是让 Claude Code 变得可靠的上下文工程层。你只要描述想法，系统会自动提取它需要知道的一切，然后让 Claude Code 去干活。

具体来说，这个仓库给用户提供如下的指导：

- 如何组织一个cc-native的repo，这样一个repo应该长什么样子？
- 一些通用的skills, agents, commands, etc. 适用于我们上面所说的cc-native的repo。
- 一些在这些cc-native repo里面coding的best practice。

## 如何组织一个 cc-native 的 repo

一个真理：Claude 的 context window 填充很快，填得越满表现越差。所以 cc-native 的 repo 怎么设计，目标只有一个：让 CC 在做事的时候少读没用的东西。

从宏观看，一个 cc-native 的 repo 有三个核心部分：CLAUDE.md、docs、tests。其他文件夹随便。大概长这样：

```
my-repo/
├── CLAUDE.md                       # 一句话介绍 + 目录结构 + 用户约束，越短越好
├── docs/
│   ├── README.md                   # docs 总索引
│   ├── GIT.md                      # 分支 / commit / PR 规范
│   ├── SECURITY.md                 # CC 不能做的事（secrets、敏感文件）
│   ├── arch/                       # 模块在干什么、当前为什么这么设计
│   │   ├── README.md
│   │   ├── auth.md
│   │   └── pipeline.md
│   ├── experience/                 # 踩过的坑：症状 → 根因 → 解法
│   │   ├── README.md
│   │   ├── b300-pip-install-glibc.md
│   │   └── multiprocessing-vs-threading.md
│   ├── roadmap/                    # 想做但还没做的事
│   │   ├── README.md
│   │   └── add-streaming-mode.md
│   └── reference/                  # 外部资料：别的 repo、paper 笔记
│       ├── README.md
│       └── claude-api-prompt-caching.md
├── tests/                          # ci/cd测试，cc和用户都能跑，但是更改一定谨慎
└── src/                            # 其他随便
```

### CLAUDE.md

CLAUDE.md 每一轮对话都会被预置进 system prompt，所以里面每个字节都是按对话次数计费的。这意味着它必须非常简短：一句话仓库介绍、目录结构、几条最关键的用户约束。什么内容进 CLAUDE.md 什么进 docs，判断很简单——每次对话都用得上的进 CLAUDE.md，其他都进 docs。这是符合真理的。

### docs

docs 是 cc-native repo 里最核心的部分。它的存在让 CC 能 grep 短的 md 搞清楚 code 在干什么，最后精确定位到真正要读的源文件，而不是上来就 grep 一堆代码。这是符合真理的。

docs 顶层有两份指路文档放在子目录之外：**GIT.md** 写本仓库的分支、commit、PR 规范，**SECURITY.md** 写 CC 不能做的事（比如不准把 API key 写进代码、哪些文件不准读）。这两份 CC 几乎每次动手都该过一眼，所以不塞进子目录。

docs 下面有几个子目录：

**arch** 写每个模块在干什么、模块之间怎么连、当前为什么这么设计。它跟代码一起长期演化。CC 接到任务、准备动某块代码之前，先扫一眼 arch。arch 不要逐行复述代码在干什么，那种东西既会过时也没省 context，CC 还得回去读源码确认。arch 只写代码表达不了的部分：设计意图、tradeoff、跨模块的约束。

**experience** 写以前出过什么事，比如某次踩坑、环境配置、调试故事。每条都是症状 → 根因 → 解法三段式。比如在 B300 上 pip install 卡死，根因是 GLIBC 版本，解法用 conda 装。CC 看到某个错误信息或者奇怪现象的时候去看 experience，确认是不是已知问题。experience 是只增不删的，按事件归档。如果某条经验抽象成了项目通用规则，比如这个项目永远不要用 threading，那就升级到 arch 或 CLAUDE.md，从 experience 里毕业。

**roadmap** 之前想做但还没做的事情。这帮助用户回忆，也帮 CC 接到新任务的时候先看看是不是已经有半成型的方案要对齐。

**reference** 相关的外部资料，比如另一个仓库的信息、学到的 paper 的知识。这防止 CC 再去查一遍已经知道的东西，消耗没意义的 context。这是符合真理的。

每个子目录里都有一个 README.md 做索引，docs/ 根目录也有一个 README.md 介绍这四个子目录分别在干什么。子目录之间的文档可以互相引用，方便 CC 看到一件事相关的所有材料。

### tests

tests 跟 docs 一样核心。它让 CC 改完代码能自己跑测试 / lint / build 确认对错，不用你来当反馈源。注意！这里面的测试尽量不要让cc随便vibe，可以随便跑但是不要随便vibe新的测试（防止hacking）。

### 维护是设计的一部分

上面这套只在文档不漂移的时候才成立。docs 里引用的代码路径会过期、子目录的 README 索引会跟实际文件对不上、CLAUDE.md 的项目地图会跟着代码一起漂。所以 cc-native 的 repo 一开始就得把维护规划进去，这正是后面 /mika-doc-gardening、/mika-create-experience、/mika-cc-native-audit 这些 skill 的用武之地。

## Skills（用户可调用）

> 所有 skill / agent 都加 `mika-` 前缀，标记为本项目集合，避免和 built-in 或其他共享集合重名。

### `/mika-cc-init` — 一键搭 cc-native 骨架

生成 `CLAUDE.md` 模板 + `docs/` 整套结构（README、GIT.md、SECURITY.md、四个子目录及各自 README）。**永远不覆盖任何已存在的文件**——只创建缺失的，跳过的也会列出来。新 repo 起步或老 repo 改造都安全。

### `/mika-create-experience` — 经验沉淀

把当前对话里刚解决的问题提炼成一份 `docs/experience/<slug>.md`，三段式（症状 → 根因 → 解法）并更新索引。最佳触发时机就是问题刚搞定的那一刻——CC 自己最清楚来龙去脉。

### `/mika-create-arch` — 模块 arch 文档

调起 `mika-arch-writer` agent 在干净 context 里读模块源码 + README，起草 `docs/arch/<module>.md`。重点是写设计意图、tradeoff、跨模块约束——拒绝逐行复述代码（cc-native 的反模式）。

### `/mika-add-roadmap` — 想法入档

把"想做但不打算现在做"的事存进 `docs/roadmap/`。强制要求填写阻塞理由，避免 roadmap 沦为无差别堆积。CC 接到相关新任务时会先看这里对齐已有方案。

### `/mika-save-reference` — 外部资料入库

读到 paper / 博客 / API 文档之后，提炼成 TL;DR + 关键点 + 适用场景，存到 `docs/reference/`。下次 CC 不用再 webfetch，省 context 也省时间。

### `/mika-doc-gardening` — 修文档内容漂移

调起 `mika-doc-ref-audit` agent 扫描 markdown 里所有代码锚点（文件路径、函数名、CLI 参数等），验证是否还匹配代码。高置信度自动修，有歧义的标出来等用户拍板。

### `/mika-doc-updating` — README 同步

调起 `mika-doc-readme-sync` agent 给受影响的目录补 README，写代码读不出来的部分（设计意图、踩坑、上下游耦合）。可以指定目录，也可以从 git diff 自动检测。

### `/mika-cc-native-audit` — 结构健康检查

调起 `mika-cc-native-auditor` agent 审 cc-native 结构漂移：CLAUDE.md 是不是胖了、docs/ 子目录全不全、每个模块有没有对应的 arch 文档。和 `/mika-doc-gardening` 互补——一个修内容、一个审结构。

### `/mika-cmp` — 自动提交合并推送

自动分析工作区所有未提交的改动，按类型（feat/fix/doc/refactor 等）分类，每类在独立分支上提交，然后合并回 main 并推送。省去手动分支、分类提交的繁琐操作。

### `/mika-write-shell-script` — 写 Shell 脚本

根据复杂度自动选择两种风格之一：简单脚本用扁平结构直接写，复杂脚本用命名数组分段组织参数。内置严格模式、日志管道等最佳实践，避免写出过度防御或模板化的脚本。

### `/mika-agent-debugger` — 对抗式 Bug 审计

两阶段流程：先用多个并行 agent 扫描代码库发现潜在 bug，然后自己逐条对抗验证——读源码、追调用链、查 API 契约，淘汰误报。只有经过验证的真实 bug 才会出现在最终报告里。

## Agents（由 Claude 自动调度）

### `mika-bug-scanner` — Bug 扫描器

系统性扫描代码库，按优先级检查并发问题、数据管道错误、逻辑缺陷、API 集成和 CLI 配置等方面。只读不执行，按严重程度输出结构化报告。

### `mika-bug-verifier` — Bug 验证器

扮演魔鬼辩护人角色，对每一条 bug 报告进行对抗式审查。通过读源码、追踪调用方、检查 API 契约等手段，尝试证明每个发现不是 bug。只有无法推翻的才标记为真实缺陷。

### `mika-arch-writer` — Arch 文档起草

由 `/mika-create-arch` 调起。读模块源码 + 邻近 README，起草 `docs/arch/<module>.md`。强制写"代码读不出来"的部分（设计意图、tradeoff、跨模块约束），拒绝罗列函数签名或贴大段代码。

### `mika-cc-native-auditor` — cc-native 结构审计

由 `/mika-cc-native-audit` 调起。检查 CLAUDE.md 大小、docs/ 子目录完整性、README 索引存在性、arch 覆盖率、孤儿 arch 文档。报告分 Missing / Stub / Drift 三档，每条带具体修复命令建议。

### `mika-doc-review` — 文档 AI 友好度审查

用六条原则评估项目文档是否对 AI agent 友好：显式优于隐式、声明作用范围、反例比正例有效、机器可读结构、记录决策原因、提供入口地图。给出具体修改建议而非泛泛评价。

### `mika-doc-ref-audit` — 文档引用审计

提取所有 markdown 文件中的代码锚点（文件路径、函数名、CLI 参数、字段名、交叉链接），逐一与代码库交叉验证。路径改了自动修、函数名换了自动更新，有歧义的标记待确认。

### `mika-doc-readme-sync` — README 同步

检查哪些目录缺少 README、已有 README 的索引表是否与实际文件匹配、CLAUDE.md 的项目地图是否漂移。自动修复简单问题（删除已不存在的条目、补充新增的文件），结构性变更留给用户决定。

### `mika-simplify-claude-md` — 精简 Agent/Skill 定义

扫描 `.claude/agents/` 和 `.claude/skills/` 下的 markdown 文件，将超过 500 词的文件精简到限额内。砍掉框架已内置的行为描述和冗长的方法论，保留路由必需的 frontmatter、项目特定约束和关键规则。
