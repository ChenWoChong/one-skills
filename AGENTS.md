# 维护指南

这个仓库用于沉淀个人 Codex skills。后续维护时请遵守以下约定：

- 所有面向人阅读的文档统一使用中文编写，包括 `README.md`、`docs/` 下的文档、skill 的 `SKILL.md` 正文和模板文档。
- skill 名称、目录名、脚本名、配置字段名保持英文小写短横线风格，例如 `linus-go-cleanup`。
- 每个 skill 必须是自包含目录，放在 `skills/<skill-name>/` 下。
- 每个 skill 只要求包含 `SKILL.md`；只有确实需要时才添加 `scripts/`、`references/`、`assets/`。
- 不要在单个 skill 内添加 README、安装指南、更新日志等额外说明文件，除非 Codex 执行该 skill 时确实需要读取。
- 修改后运行 `scripts/validate-skills`。
