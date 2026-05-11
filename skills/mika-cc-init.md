---
name: mika-cc-init
description: "Scaffold a cc-native repo skeleton — creates CLAUDE.md template + docs/{README,GIT,SECURITY}.md + docs/{arch,experience,roadmap,reference}/README.md. NEVER overwrites any file that already exists. Use to bootstrap a new repo or retrofit an existing one into cc-native shape."
user_invocable: true
---

# CC Init — Scaffold a CC-Native Repo

一键搭出 cc-native 骨架（CLAUDE.md + docs/ 子结构）。

## 最重要的约束

**永远不覆盖任何已存在的文件。** 对每个目标文件先检查存在性，存在就跳过、跳过原因写进报告。这是这个 skill 的全部价值所在——用户敢在已有 repo 上跑而不怕丢东西。

## 生成清单

只在文件不存在时创建：

| 路径 | 模板内容 |
|---|---|
| `CLAUDE.md` | 一句话仓库介绍占位 + 目录结构 + 用户约束 section |
| `docs/README.md` | 四个子目录的索引 + GIT.md / SECURITY.md 入口 |
| `docs/GIT.md` | 分支命名、commit message 风格、PR 流程占位 |
| `docs/SECURITY.md` | 禁止提交 secrets、禁读文件 pattern 占位 |
| `docs/arch/README.md` | arch 是什么 + 索引占位 |
| `docs/experience/README.md` | experience 是什么 + 索引占位 |
| `docs/roadmap/README.md` | roadmap 是什么 + 索引占位 |
| `docs/reference/README.md` | reference 是什么 + 索引占位 |

## Procedure

### 1. 不要预设当前目录是空的

跑 `pwd` 和 `ls -la` 确认在哪。如果目录非空且不是 git repo，问用户："这是要 init 的目标 repo 吗？"

### 2. 逐项检查 + 创建

对清单里每个文件：

```bash
[ -f <path> ] && echo "skip: <path>" || mkdir -p $(dirname <path>) && write <path>
```

mkdir -p 是 idempotent 的，目录已存在不会报错。但 **文件检查必须在写之前**，不要用 `>` 重定向（会覆盖）。

### 3. 模板内容

#### CLAUDE.md

```markdown
# <repo name>

<一句话介绍这个 repo 在干什么。删掉这行的占位符。>

## 结构

- `docs/` — CC 的导航层（arch、experience、roadmap、reference）。详见 `docs/README.md`
- `tests/` — 验证用，CC 可以跑但慎改
- `<其他目录>` — TODO

## 约束

- 详细的 git 规范见 `docs/GIT.md`
- 安全规则见 `docs/SECURITY.md`
- TODO: 项目特定的最关键约束写在这里（每条对话都要遵守的那种）
```

#### docs/README.md

```markdown
# docs

CC 的导航层。让 CC 能 grep 短的 md 搞清楚 code 在干什么，最后精确定位到要读的源文件。

## 入口文档

- [GIT.md](GIT.md) — 分支、commit、PR 规范
- [SECURITY.md](SECURITY.md) — CC 不能做的事

## 子目录

- [arch/](arch/) — 模块在干什么、当前为什么这么设计
- [experience/](experience/) — 踩过的坑：症状 → 根因 → 解法
- [roadmap/](roadmap/) — 想做但还没做的事
- [reference/](reference/) — 外部资料（paper、其他 repo）
```

#### docs/GIT.md

```markdown
# Git 规范

## 分支

- `main` — TODO: 描述 main 的角色（受保护？只能 PR 合？）
- `<feature-branch-pattern>` — TODO: 命名规则

## Commit message

- 格式：TODO（例：`[fix] xxx`、`feat: xxx`、conventional commits 等）
- 范围：TODO（一次 commit 只做一件事？允许多文件？）

## PR 流程

- TODO: 谁能 review、需要几个 approval、是否要 squash merge
```

#### docs/SECURITY.md

```markdown
# Security 规范

CC 在这个 repo 里不能做的事。

## 永远不准

- 提交任何 secret（API key、token、密码、私钥）到 git
- 读取 `.env`、`.env.*`、`**/*credential*`、`**/*.pem`、`**/*.key` 等敏感文件
- 把上述内容贴到对话、commit message、PR 描述里

## 涉及敏感数据时

- TODO: 项目特有的敏感数据处理规则（例：用户数据脱敏、日志过滤等）

## 配置参考

建议在 `.claude/settings.json` 里加 deny 规则：

\`\`\`json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/secrets/*)",
      "Read(**/*credential*)",
      "Read(**/*.pem)",
      "Read(**/*.key)"
    ]
  }
}
\`\`\`
```

#### docs/arch/README.md

```markdown
# arch

每个模块在干什么、模块之间怎么连、当前为什么这么设计。CC 接到任务、准备动某块代码之前先扫一眼。

**写什么**：设计意图、tradeoff、跨模块约束。

**不写什么**：逐行复述代码——那种东西既会过时也没帮 CC 省 context（CC 还得读源码确认）。

## 索引

<!-- TODO: 模块 -> arch 文档对应表 -->
- [<module>](<module>.md) — <一句话>
```

#### docs/experience/README.md

```markdown
# experience

踩过的坑。每条文档三段式：症状 → 根因 → 解法。CC 看到错误信息或奇怪现象时来这里查。

只增不删。如果某条经验抽象成了项目通用规则，升级到 `docs/arch/` 或 `CLAUDE.md`，从这里毕业。

用 `/mika-create-experience` 自动捕捉。

## 索引

<!-- TODO -->
- [<slug>](<slug>.md) — <一句话什么问题>
```

#### docs/roadmap/README.md

```markdown
# roadmap

想做但还没做的事。CC 接到新任务时先看一眼，对齐已有的半成型方案。

用 `/mika-add-roadmap` 添加新条目。

## 索引

<!-- TODO -->
- [<slug>](<slug>.md) — <一句话动机>
```

#### docs/reference/README.md

```markdown
# reference

相关的外部资料：paper、博客、API 文档、其他 repo 的关键信息。防止 CC 重复 webfetch。

用 `/mika-save-reference` 添加。

## 索引

<!-- TODO -->
- [<slug>](<slug>.md) — <一句话来源 + 主题>
```

### 4. 报告

按以下结构打印：

```
Created (<n>):
  - <path1>
  - <path2>
  ...

Skipped — already exists (<m>):
  - <path1>
  - <path2>
  ...

Next steps:
  - 编辑 CLAUDE.md 把 TODO 占位换成真实内容
  - 在 docs/GIT.md 和 docs/SECURITY.md 里填项目特有的规则
  - 用 /mika-create-arch 给现有模块补 arch 文档
```

## What This Skill Does NOT Do

- 不创建 `tests/` 和 `Makefile`——这两个项目特异性太强，模板会用不上
- 不修改任何已存在文件，包括只是补内容
- 不写真实的项目内容，只写带 TODO 的占位模板
- 不跑 `git init`——那是用户的决定
- 不跑 `git add` / `git commit`——只创建文件，提交由用户决定
