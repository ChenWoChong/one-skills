# 技能约定

## 命名

- 只使用小写字母、数字和短横线。
- skill 目录名必须和 `SKILL.md` 里的 `name` 字段一致。
- 优先使用简短、动作导向的名称。

## SKILL.md

- frontmatter 只保留 `name` 和 `description`。
- 触发场景写在 `description` 里；Codex 会先读它，再决定是否加载 skill 正文。
- 正文只写 Codex 不一定知道的流程、判断标准和项目规则。
- 长示例、schema、详细参考资料放进 `references/`。

## 资源目录

- `scripts/` 放需要稳定重复执行的脚本。
- `references/` 放只在特定任务中才需要读取的参考资料。
- `assets/` 放模板、图片、初始文件或其他输出资源。
- 单个 skill 内不要添加额外说明文档，除非 Codex 执行任务时确实需要读取。

## 维护

- 修改后运行校验。
- 示例要贴近真实使用方式。
- 当规则不再匹配实际用法时，及时删除或改写。
