# 个人 Codex Skills

这个仓库用于保存我在日常开发过程中沉淀下来的个人 Codex skills。

## 目录结构

```text
one-skills/
├── skills/                  # 每个子目录是一个自包含 skill
├── templates/skill-template/ # 新 skill 的最小模板
├── scripts/                 # 仓库维护脚本
└── docs/                    # 仓库约定和未成形想法
```

`skills/` 下的每个目录都应该是一个完整 skill：

```text
skill-name/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── scripts/
├── references/
└── assets/
```

只有 `SKILL.md` 是必需的。仅当 skill 真实需要时，才添加 `scripts/`、`references/` 或 `assets/`。

## 常用命令

创建新的 skill 骨架：

```bash
make new-skill NAME=my-skill
```

列出当前项目下所有 skills：

```bash
make skills
```

校验所有 skills：

```bash
make validate
```

把仓库里的 skills 链接到 Codex 的本地发现目录：

```bash
make link-to-codex
```

## 查看技能

当前技能列表由 `skills/*/SKILL.md` 动态生成：

```bash
make skills
```
