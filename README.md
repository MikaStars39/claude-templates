# Claude Code Done Right

这个仓库尝试总结一些我自己觉得如何组织Claude Code高效完成工作的经验，套用GSD的一句话：

> Vibecoding 的名声不算好。你描述需求，AI 生成代码，结果往往是质量不稳定、规模一上来就散架的垃圾。它是让 Claude Code 变得可靠的上下文工程层。你只要描述想法，系统会自动提取它需要知道的一切，然后让 Claude Code 去干活。

具体来说，这个仓库给用户提供如下的指导：

- 如何组织一个cc-native的repo，这样一个repo应该长什么样子？
- 一些通用的skills, agents, commands, etc. 适用于我们上面所说的cc-native的repo。
- 一些在这些cc-native repo里面coding的best practice。

## 1. 如何组织一个 cc-native 的 repo

> [!IMPORTANT]
> 一个真理：Claude 的 context window 填充很快，填得越满表现越差。所以 cc-native 的 repo 怎么设计，目标只有一个：让 CC 在做事的时候少读没用的东西。

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
    #
    # 任何你这个项目其他的代码
    # 
```

### 1.1 CLAUDE.md

CLAUDE.md 每一轮对话都会被预置进 system prompt，所以里面每个字节都是按对话次数计费的。这意味着它必须非常简短：一句话仓库介绍、目录结构、几条最关键的用户约束。什么内容进 CLAUDE.md 什么进 docs，判断很简单——每次对话都用得上的进 CLAUDE.md，其他都进 docs。这是符合真理的。

### 1.2 docs

docs 是 cc-native repo 里最核心的部分。它的存在让 CC 能 grep 短的 md 搞清楚 code 在干什么，最后精确定位到真正要读的源文件，而不是上来就 grep 一堆代码。这是符合真理的。

docs 顶层有两份指路文档放在子目录之外：

- **GIT.md** 写本仓库的分支、commit、PR 规范。
- **SECURITY.md** 写 CC 不能做的事（比如不准把 API key 写进代码、哪些文件不准读）。这两份 CC 几乎每次动手都该过一眼，所以不塞进子目录。

docs 下面有几个子目录：

- **arch** 写每个模块在干什么、模块之间怎么连、当前为什么这么设计。它跟代码一起长期演化。CC 接到任务、准备动某块代码之前，先扫一眼 arch。arch 不要逐行复述代码在干什么，那种东西既会过时也没省 context，CC 还得回去读源码确认。arch 只写代码表达不了的部分：设计意图、tradeoff、跨模块的约束。

- **experience** 写以前出过什么事，比如某次踩坑、环境配置、调试故事。每条都是症状 → 根因 → 解法三段式。比如在 B300 上 pip install 卡死，根因是 GLIBC 版本，解法用 conda 装。CC 看到某个错误信息或者奇怪现象的时候去看 experience，确认是不是已知问题。experience 是只增不删的，按事件归档。如果某条经验抽象成了项目通用规则，比如这个项目永远不要用 threading，那就升级到 arch 或 CLAUDE.md，从 experience 里毕业。

- **roadmap** 之前想做但还没做的事情。这帮助用户回忆，也帮 CC 接到新任务的时候先看看是不是已经有半成型的方案要对齐。

- **reference** 相关的外部资料，比如另一个仓库的信息、学到的 paper 的知识。这防止 CC 再去查一遍已经知道的东西，消耗没意义的 context。这是符合真理的。

每个子目录里都有一个 README.md 做索引，docs/ 根目录也有一个 README.md 介绍这四个子目录分别在干什么。子目录之间的文档可以互相引用，方便 CC 看到一件事相关的所有材料。

### 1.3 tests

tests 跟 docs 一样核心。它让 CC 改完代码能自己跑测试 / lint / build 确认对错，不用你来当反馈源。注意！这里面的测试尽量不要让cc随便vibe，可以随便跑但是不要随便vibe新的测试（防止hacking）。

> [!IMPORTANT]
> 维护是设计的一部分
>
> 上面这套只在文档不漂移的时候才成立。docs 里引用的代码路径会过期、子目录的 README 索引会跟实际文件对不上、CLAUDE.md 的项目地图会跟着代码一起漂。所以 cc-native 的 repo 一开始就得把维护规划进去，这正是后面 /mika-doc-gardening、/mika-create-experience、/mika-cc-native-audit 这些 skill 的用武之地。

## 2. Skills 和 Agents

> 所有 skill / agent 都加 `mika-` 前缀，标记为本项目集合，避免和 built-in 或其他共享集合重名。

CC 这套生态有两种入口：

- **Skills**——你在对话里直接打 `/mika-xxx` 触发的显式工作流。
- **Agents**——通常被某个 skill 起，或者 CC 觉得合适时自己调起来。是后台干活的工人。

### 2.1 Skills（用户可调用）

按用途分四档：**初始化** → **沉淀到 docs/** → **维护文档** → **代码 & Git 工作流**。前三档对应 cc-native repo 的生命周期，第四档是通用的开发辅助。

| 阶段 | Skill | 用途 |
|------|-------|------|
| **初始化** | `/mika-cc-init` | 一键搭 cc-native 骨架（`CLAUDE.md` + `docs/` 整套结构）。永远不覆盖已存在的文件，老 repo 改造也安全。 |
| **沉淀到 docs/** | `/mika-create-arch` | 调起 `mika-arch-writer` 在干净 context 里起草 `docs/arch/<module>.md`，重点写设计意图、tradeoff、跨模块约束。 |
|  | `/mika-create-experience` | 把当前对话里刚解决的问题提炼成 `docs/experience/<slug>.md`，三段式（症状 → 根因 → 解法）。问题刚搞定立刻跑。 |
|  | `/mika-add-roadmap` | 把"想做但不打算现在做"的事存进 `docs/roadmap/`，强制要求填阻塞理由。 |
|  | `/mika-save-reference` | 读完 paper / 博客 / API 文档后提炼成 TL;DR + 关键点存到 `docs/reference/`。下次不用再 webfetch。 |
| **维护文档** | `/mika-doc-gardening` | 调起 `mika-doc-ref-audit` 扫 markdown 里的代码锚点（文件路径、函数名、CLI 参数），验证是否过期，高置信度自动修。 |
|  | `/mika-doc-updating` | 调起 `mika-doc-readme-sync` 给受影响的目录补 README，写代码读不出来的部分（设计意图、踩坑、上下游耦合）。 |
|  | `/mika-cc-native-audit` | 调起 `mika-cc-native-auditor` 审 cc-native 结构漂移：CLAUDE.md 是不是胖了、docs/ 子目录全不全、arch 覆盖率。和 doc-gardening 互补，一个修内容一个审结构。 |
| **代码 & Git** | `/mika-cmp` | 自动按类型（feat/fix/doc/refactor）分类未提交的改动，每类独立分支提交后合并到 main 并推送。一条命令搞定整个 git 工作流。 |
|  | `/mika-write-shell-script` | 按复杂度选风格写 Shell 脚本（简单扁平、复杂用命名数组分段），内置严格模式等最佳实践。 |
|  | `/mika-agent-debugger` | 两阶段：先并行 agent 扫 bug，再逐条对抗验证淘汰误报，只输出确认的 bug。 |

### 2.2 Agents（CC 自动调度）

Agent 大部分是被 skill 起的，少数是 CC 看到合适场景自己调起来。一般你不用直接关心 agent，知道有这些工人在背后干活就行。

| Agent | 用途 | 由谁调起 |
|------|------|----------|
| `mika-arch-writer` | 起草 arch 文档（设计意图、tradeoff、跨模块约束）。 | `/mika-create-arch` |
| `mika-cc-native-auditor` | 审 cc-native 结构漂移，分 Missing / Stub / Drift 三档报告。 | `/mika-cc-native-audit` |
| `mika-doc-ref-audit` | 扫 markdown 里的代码锚点，验证是否过期。 | `/mika-doc-gardening` |
| `mika-doc-readme-sync` | 给目录补 README，记录设计意图、踩坑、上下游耦合。 | `/mika-doc-updating` |
| `mika-doc-review` | 用六条原则评估文档对 AI agent 是否友好。 | CC 自动 |
| `mika-bug-scanner` | 系统性扫描代码库找 bug，按严重程度输出结构化报告。 | `/mika-agent-debugger` |
| `mika-bug-verifier` | 对每条 bug 报告做对抗式审查，淘汰误报。 | `/mika-agent-debugger` |
| `mika-simplify-claude-md` | 把超过 500 词的 agent/skill md 精简到限额内。 | CC 自动 |

## 3. 一个完整的例子：从空 repo 到第一个 PR

光看分类表抓不到节奏感。下面用一个虚构项目 `my-pipeline`（一个数据处理流水线）从零开始，把所有 skill 串成一条真实的开发流。

### Step 1 — 初始化骨架

新 repo 第一件事：

```
/mika-cc-init
```

生成 `CLAUDE.md` 模板 + `docs/` 整套结构（GIT.md、SECURITY.md、四个子目录及各自 README）。后面所有 skill 都假设这个结构存在。

### Step 2 — 给已有模块写 arch

`src/ingest/` 已经有一些代码，让 CC 起草一份 arch：

```
/mika-create-arch src/ingest
```

`mika-arch-writer` agent 在干净 context 里读模块源码 + 邻近 README，输出 `docs/arch/ingest.md`，重点是设计意图、tradeoff、跨模块约束——而不是逐行复述代码。

### Step 3 — 接到新需求，先看 roadmap

老板说要加 streaming 模式。CC 接任务的第一动作是 grep `docs/roadmap/`，看看是不是已经有半成型的方案要对齐。如果有，按已有方向走；没有，再走正常开发流程。

### Step 4 — 开发过程踩坑，沉淀经验

debug 时发现 multiprocessing 在 macOS 上 fork 会卡死，换 spawn 模式就好了。问题刚搞定的那一刻：

```
/mika-create-experience
```

CC 把症状 → 根因 → 解法写到 `docs/experience/multiprocessing-macos-fork.md`。下次再撞同样的错就能直接在 experience 里查到，不用从头 debug。

### Step 5 — 用了一篇 paper，存 reference

读了一篇关于 backpressure 控制的 paper，提炼后入库：

```
/mika-save-reference
```

下次 CC 要做相关设计不用再 webfetch，省 context 也省时间。

### Step 6 — 又想到一个 feature，但不打算现在做

```
/mika-add-roadmap
```

强制填阻塞理由（"等 v2 schema 落地后再做"），避免 roadmap 沦为愿望清单。下次 Step 3 的时候它就会被检索到。

### Step 7 — bug 自检

写完了想确认没引入新 bug：

```
/mika-agent-debugger
```

并行 agent 扫一遍 → 对抗验证淘汰误报 → 只输出确认的 bug。不会被一堆 false positive 噪音淹没。

### Step 8 — 维护文档（三件套）

代码动了不少，docs 大概率漂了。三件套并行修：

```
/mika-doc-gardening      # 扫 markdown 里过期的代码锚点
/mika-doc-updating       # 给改过的目录补/更新 README
/mika-cc-native-audit    # 检查 cc-native 结构是否还健康
```

这一步是 cc-native 的命门——不维护，docs 漂了，后续所有 skill 的输出质量都跟着掉。

### Step 9 — 提交

最后：

```
/mika-cmp
```

CC 自动按 feat/doc/fix/refactor 分类所有改动，每类独立分支提交，merge 到 main，push。一条命令搞定。
