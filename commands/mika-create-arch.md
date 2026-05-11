
# Create Arch — Draft an Arch Doc for a Module

给指定模块起草 `docs/arch/<module>.md`。重点是写代码表达不了的部分。

## When to Use

- 刚加完一个新模块
- 已有模块还没 arch 文档
- 用户说"给 X 写个 arch" / "把 X 模块文档化"

## Procedure

### 1. 确认模块

参数解析：`/mika-create-arch <module>` 里 `<module>` 是模块路径或模块名。

如果用户没给参数，用 `AskUserQuestion` 问："要给哪个模块写 arch？" 列出 `src/` 下的子目录供选择。

如果给的是名字（不是路径），用 glob 找一下：`src/<name>/`、`<name>/`。找到一个就用，找到多个让用户选，一个都没找到问用户。

### 2. 检查是否已有 arch 文档

`[ -f docs/arch/<module>.md ]`。已有就告诉用户："`docs/arch/<module>.md` 已存在。要追加 / 重写 / 取消？" 不要默认覆盖。

### 3. 启动 mika-arch-writer agent

把读模块 + 起草的工作交给 `mika-arch-writer` agent，原因是这些操作会读大量源码，放在干净 context 里能省 token、不污染主对话。

prompt 给 agent：

> 模块路径：`<absolute path>`
> 输出路径：`docs/arch/<module>.md`
>
> 读这个模块下的源文件 + 任何 README，起草一份 arch 文档。
>
> 必须写：设计意图（为什么这样设计，备选方案是什么、为什么没选）、tradeoff、跨模块约束（这个模块依赖谁、谁依赖它、契约是什么）、关键不变量。
>
> 严格禁止：逐行复述代码在干什么、列函数签名、贴大段代码片段。"代码说 what，arch 说 why"。
>
> 控制在 200 行以内。如果模块大到塞不进，按子模块拆，文档里只写顶层结构 + 链接到子模块的 arch 文档（agent 不要自己拆，只在文档里建议拆法让用户决定）。
>
> 写完后输出文件路径 + 一段简短摘要给我。

### 4. 审核 + 入库

agent 返回后：

- 读一下生成的文件
- 检查反模式：有没有逐行复述、有没有大块代码片段。有就告诉用户、问是否让 agent 重写
- 没问题就更新 `docs/arch/README.md` 索引

### 5. 报告

告诉用户：
- 文件路径
- 内容大致涵盖什么
- 索引更新情况
- 用户应该手动审一遍——arch 是 "why" 的文档，AI 推断的 why 不一定准

## What This Skill Does NOT Do

- 不写代码教程——arch 不是 README 的复制品
- 不替代 `/mika-doc-updating`——后者是同步零碎更新，这个是从零起草
- 不自动重组代码——只写文档，不改源
