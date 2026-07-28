# 网络契约（`teamo_libs/net`）

> **触发条件**：改 `teamo_libs/net/lib/**` 的任何文件；新增 `NetCode` 成员；改 `_parse` / 拦截器 / 请求方法签名时。
> **判据**：本文件 §四 Checklist；改动后必须在 App 侧真机跑一遍完整请求链路（解析错误 analyze 测不出）。
> **单一真相源**：`teamo_libs/net/lib/response.dart`（响应结构）+ `request_mixin.dart::_parse`（解析入口）。

---

## 一、为什么这个库需要单独的规则

`net` 是**三端共享的契约层**：后端 `ResponseWrapper` 产出的结构、App 消费的结构，唯一的交汇点就是这里。
改它等于同时改后端约定和 App 行为，但它自己不在任何一个子项目的规则覆盖范围内——历史上这里是规则空白区。

依赖方：`teamo_helper/pubspec.yaml` 以本地路径引入 `net`。**它没有版本号隔离，改了立刻影响 App。**

---

## 二、响应结构契约（改动 = 跨端 breaking change）

| 元素 | 现状 | 约束 |
|---|---|---|
| body 结构 | `{code, message, data}` | 后端 `utils/response_wrapper.py` 必须产出同构；见 [`response-wrapper.md`](../../../teamo/.claude/rules/response-wrapper.md) |
| `NetCode` 成员 | `success(0)` / `clientError(400)` / `authFail(401)` / `conflict(409)` / `unknownError(-1)` | 新增成员必须同时确认后端会发出该值；`@JsonValue` 必须与后端 HTTP 语义对齐 |
| `unknownEnumValue` | 已设为 `unknownError` | **只对「字段存在但值不认识」生效**；`code` 字段**缺失**时仍抛 `A value must be provided`——所以后端任何接口都不能不包 |
| `shouldRelaunch` | 仅 `authFail` | 加成员时想清楚它该不该触发重登 |

新增 `NetCode` 成员是 **append-only**：不要改已有成员的 `@JsonValue`，那会让线上旧包对同一数字解出不同语义。

---

## 三、`_parse` 的既有行为（改之前必须知道）

| 行为 | 说明 |
|---|---|
| debug 下 rethrow | `!kReleaseMode` 时解析异常**重新抛出**。所以调用方写 `catch (_) { continue; }` 会把它静默吞掉，表现为「接口 200 但 UI 卡住」——见 [`net-json-decode-casts.md`](../../../teamo_helper/.claude/rules/net-json-decode-casts.md) §2.5 |
| 解码产物类型 | Dio 给的嵌套对象是 `_Map<dynamic, dynamic>`、数组是 `List<dynamic>`。**decoder 里禁止 `as Map<String, dynamic>`** |
| 无 HTTP 缓存 | 拦截器只有 `Net2Interceptor`（改写）+ `Net2LogInterceptor`（日志），并发 `Cache-Control: no-cache`。**排查「第二次请求拿到旧数据」时不要怀疑本层** |

改 `_parse` 的错误处理分支时，**必须**同时确认 debug 与 release 两条路径的行为差异是有意的。

---

## 四、Checklist

- [ ] 改了 `response.dart` → 后端 `ResponseWrapper` 是否仍产出同构 body？
- [ ] 新增 `NetCode` 成员 → 是 append-only 吗？后端确实会发这个值吗？`shouldRelaunch` 要不要带上？
- [ ] 改了 `_parse` → debug rethrow 与 release 兜底两条路径是否都想清楚了？
- [ ] 新增拦截器 → 有没有引入缓存 / 重试语义？若有，必须在本文件 §三 登记（否则下次排查会被误导）
- [ ] 改动后是否在 App 真机跑过完整请求链路？（`flutter analyze` 测不出解析期崩溃）
- [ ] 引入新依赖 → 是否登记进 `teamo_libs/net/pubspec.yaml` + lock（见 [`dependency-manifest.md`](../../../.claude/rules/dependency-manifest.md)）

---

## 五、相关规则

| 规则 | 关系 |
|---|---|
| [`response-wrapper.md`](../../../teamo/.claude/rules/response-wrapper.md) | 契约的后端一侧 |
| [`net-json-decode-casts.md`](../../../teamo_helper/.claude/rules/net-json-decode-casts.md) | 契约的 App 消费侧类型陷阱 |
| [`dependency-manifest.md`](../../../.claude/rules/dependency-manifest.md) | 本库的依赖登记 |
