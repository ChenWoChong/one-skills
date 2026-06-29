.PHONY: help new-skill validate link-to-codex

help: ## 显示可用命令
	@awk 'BEGIN {FS = ":.*## "; printf "可用命令：\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  make %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

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
