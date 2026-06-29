---
name: linus-go-cleanup
description: 用 Linus 风格审查和简化 Go 代码。适用于 Go PR 清理、gateway/session/runtime 代码优化、删除无意义 nil 或空值防御判断、删除一行包装函数和无实际使用的接口、减少 if/else 嵌套、检查职责边界、补充有排查价值的日志，以及确保测试贴近真实生产流程而不是逼生产代码增加防御性分支。
---

# Linus Go Cleanup

## 目标

在提交 PR 前，对 Go 代码做一次强硬、务实的清理。优先保证正确性、主流程清晰、抽象最少、测试贴近生产真实路径。不要因为“看起来更安全”就加代码；只有真实数据流可能产生的状态，才值得写判断。

## 工作流程

1. 先建立上下文：看调用路径、构造函数、测试、真实运行时 wiring。
2. 先理清数据生命周期：谁创建、谁持有、谁修改、谁持久化、谁关闭。
3. 删除假的特殊情况：删掉只为测试方便或想象中未来需求存在的分支、接口、包装函数和字段。
4. 保持兼容：除非用户明确接受，否则不要改变对外 API 行为。
5. 最后验证：先跑改动包的定向测试，再跑项目要求的最终检查。

## 规则

### 删除无意义防御代码

如果生产流程不可能产生某个 `nil`、空字符串、空 slice 或零值，就不要新增或保留对应判断。

优先修调用方、构造函数或测试 fake，不要为了测试场景给生产代码加防御分支。

这些判断可以保留，因为它们代表真实业务状态或外部输入：

```go
if southConn == nil { ... }      // 真实连接状态
if southID == "" { ... }         // 真实未绑定 session 状态
if err != nil { ... }            // Go 错误处理
```

如果构造流程已经保证依赖存在，就删掉这类判断：

```go
if m.store == nil { return nil } // 坏：隐藏了非法 Manager
if h.lifecycle == nil { ... }    // 坏：除非 lifecycle 真的是可选依赖
```

### 删除薄包装函数

如果一个函数只有一次真实调用，再加一点参数转发或名字包装，并且内联后更易读，就删除它。

坏例子：

```go
func (h *NorthHandler) touchSession(id acp.SessionID) {
	h.lifecycle.MarkActive(id)
}
```

更好：

```go
h.lifecycle.MarkActive(id)
```

只有在包装函数表达稳定领域概念、集中非平凡策略、隐藏易变实现细节，或明显提升调用点可读性时，才保留。

### 避免假接口

不要为了让一个 struct 调一个方法就新建接口，尤其是生产代码里没有第二个实现时。

依赖归属清楚时，优先用具体类型：

```go
lifecycle *session.Lifecycle
```

接口只放在真实边界：外部系统、多生产实现的测试缝、或者包之间确实不能依赖具体类型的地方。

### 保持主流程扁平

让 happy path 保持在函数最外层。可以用 early return 减少嵌套，但不要为了形式上的“扁平”增加代码量。

这种错误处理可以保留，不要强行压平：

```go
if err != nil {
	if errors.Is(err, context.Canceled) {
		return nil
	}
	return err
}
```

避免把大半个函数包在 `if ok { ... } else { ... }` 里。能用 early return 消掉失败路径，就让主流程露出来。

### 职责放在真正拥有数据的一层

按数据和副作用的所有权分配职责：

- API/handler 层只做参数校验、组装、转发和错误转换，不写业务生命周期规则。
- Lifecycle/reaper 负责记录活跃时间、flush touch、查找过期 session、控制回收节奏。
- Manager 负责内存 session 索引、连接状态、session detach/close、south 连接绑定；如果它拥有 resolver，sandbox claim release 也应归它。
- Store 负责持久化语义，例如 `closed_at`、只查询 active session、空更新 no-op。

如果某个类型只为执行另一个类型真正拥有的副作用而持有依赖，就把这个副作用移回真正拥有者。

### 日志必须方便排查问题

只在真实状态变化处加日志：

- connection opened / closed
- session created / bound / detached / reaped / closed
- sandbox claim release success / failure
- lifecycle start / stop、flush batch、reap batch

不要在每个小函数入口打噪音日志。日志要带稳定标识，例如 `north_session`、`south_session`、`connection`、`agent`、`cutoff`、数量。

### 测试必须贴近生产流程

不要为了满足 fake 测试而改生产代码。

如果生产流程一定会构造某个依赖，测试也应该构造它。例如，把 `NewManager(..., nil)` 改成真实 fake store，而不是在生产代码里加 `if m.store == nil`。

测试 fake 要保留真实语义。真实 store 对空更新是 no-op，fake 也应该 no-op，不要记录生产中不可能出现的事件。

### 关闭 session 语义要闭环

如果 close/reap 会写入 `closed_at`，读取路径也必须尊重这个状态：

- `GetSession` 不应把已关闭 session 当 active session 返回。
- `ListSessions` 不应继续展示已关闭且可 load 的 session。
- 如果 PR 触碰这块逻辑，测试要覆盖关闭后不再出现在 list/load 结果里。

## 审查清单

收尾前检查：

- 没有新增无真实生产路径的 `nil` 或空值判断。
- 没有保留内联后更清楚的一行包装函数。
- 没有为了想象中的未来扩展新增接口。
- 主流程更扁平，至少没有更深。
- API 层没有混入业务逻辑。
- Lifecycle 和 Manager 的职责符合数据所有权。
- 日志记录真实状态变化，不制造噪音。
- 测试使用真实语义的 fake，并断言行为，而不是实现偶然细节。
- 已执行 `gofmt`、定向测试，以及项目要求的最终检查。

## 验证

Go 仓库优先按这个顺序验证：

```bash
gofmt -w <changed-go-files>
go test ./<changed-package>
go test ./...
go vet ./...
git diff --check
```

如果仓库本身有更严格的本地规范，优先遵守仓库规范。不要每改一小点就频繁跑全量测试；等清理成型后再跑，或者在定位失败时定向跑。
