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
scripts/new-skill my-skill
```

校验所有 skills：

```bash
scripts/validate-skills
```

把仓库里的 skills 链接到 Codex 的本地发现目录：

```bash
scripts/link-to-codex
```

## 当前技能

- `linus-go-cleanup`：用强硬、务实、贴近生产流程的风格审查并简化 Go 代码。
