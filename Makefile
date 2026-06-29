.PHONY: help new-skill skills validate link-to-codex

help: ## 显示可用命令
	@awk 'BEGIN {FS = ":.*## "; printf "可用命令：\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  make %-20s \033[34m%s\033[0m\n", $$1, $$2}' $(MAKEFILE_LIST)

skills: ## 列出当前项目下所有 skills
	@if ! find skills -mindepth 2 -maxdepth 2 -name SKILL.md -print -quit | grep -q .; then \
		echo '未找到 skills'; \
		exit 0; \
	fi
	@find skills -mindepth 2 -maxdepth 2 -name SKILL.md -print | sort | while read -r skill_file; do \
		awk 'BEGIN { name = ""; description = "" } \
			/^---$$/ { fence++; next } \
			fence == 1 && /^name:[[:space:]]*/ { name = $$0; sub(/^name:[[:space:]]*/, "", name); gsub(/^"|"$$/, "", name) } \
			fence == 1 && /^description:[[:space:]]*/ { description = $$0; sub(/^description:[[:space:]]*/, "", description); gsub(/^"|"$$/, "", description) } \
			END { if (name != "") printf "%-24s \033[34m%s\033[0m\n", name, description }' "$$skill_file"; \
	done

new-skill: ## 创建新的 skill 骨架，例如 make new-skill NAME=my-skill
	@if [ -z "$(NAME)" ]; then \
		echo '用法：make new-skill NAME=my-skill' >&2; \
		exit 2; \
	fi
	@scripts/new-skill "$(NAME)"

validate: ## 校验所有 skills
	@scripts/validate-skills

link-to-codex: ## 链接 skills 到 Codex 本地发现目录
	@scripts/link-to-codex
