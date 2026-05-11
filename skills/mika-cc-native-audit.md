---
name: mika-cc-native-audit
description: "Audit a repo's cc-native structural health — checks CLAUDE.md size, docs/ subdirectory completeness, README index presence, and arch coverage per module. Complement to /mika-doc-gardening (which audits content drift). Use periodically or before a release."
user_invocable: true
---

# CC Native Audit — Structural Health Check

审 cc-native 结构是不是完整。和 `/mika-doc-gardening`（修内容漂移）互补，这个修结构漂移。

## When to Use

- 定期体检（每周 / 每个里程碑）
- release 前
- 用户说"看看 repo 的 cc-native 健康度"

## Procedure

### 1. 启动 mika-cc-native-auditor agent

把检查工作交给 `mika-cc-native-auditor` agent 在干净 context 里跑——这些检查需要遍历目录、读多个 README、grep 模块结构，主对话别污染。

prompt 给 agent：

> 审本 repo 的 cc-native 健康度。检查项：
>
> 1. **CLAUDE.md**：存在？行数 ≤ 500（每对话都加载，太胖会拖慢所有对话）？
> 2. **docs/README.md**：存在？是否索引了所有子目录？
> 3. **docs/GIT.md**：存在？是不是占位 TODO（"可写但内容为空" 也要 flag）？
> 4. **docs/SECURITY.md**：存在？是不是占位 TODO？
> 5. **docs/{arch,experience,roadmap,reference}/**：四个子目录是否都存在？
> 6. **每个子目录的 README.md**：存在？是不是占位（无实际索引条目）？
> 7. **arch 覆盖率**：列出 `src/` 下的子目录（或项目主源目录），对每个检查是否有对应的 `docs/arch/<module>.md`。给一个覆盖率百分比
> 8. **过期模块**：列出 `docs/arch/` 下有但 src/ 下已经没有对应代码的孤儿 arch 文档
>
> 输出报告分三档：
>
> - **Missing**（结构性缺失，必须补）
> - **Stub**（存在但是空 / 全是占位 TODO，应该填）
> - **Drift**（结构上多余、孤儿、不一致）
>
> 每条给修复建议（"跑 /mika-cc-init"、"跑 /mika-create-arch X"、"删掉 docs/arch/Y.md" 等）。

### 2. 呈现结果

agent 返回后直接展示报告。不自动修——这个 skill 只审不动手，因为不同问题修法不同：
- Missing → 引导用户跑 `/mika-cc-init` 或 `/mika-create-arch`
- Stub → 让用户决定要不要现在填
- Drift → 让用户决定删 / 改名 / 保留

### 3. 跟进建议

报告末尾问用户："要不要我帮你跑 `<具体修复命令>`？" 给最值得修的 1-2 条具体建议，不要列一堆。

## What This Skill Does NOT Do

- 不审 CLAUDE.md 内容好坏（那是 `mika-doc-review` 的事）
- 不修内容漂移（路径过期、函数名换了等——`/mika-doc-gardening` 干那个）
- 不自动创建任何文件——只报告
- 不评估代码质量
