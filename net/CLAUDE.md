# Net Package

Flutter/Dart HTTP networking library built on Dio.

## Build Commands

```bash
# 安装依赖
flutter pub get

# 代码生成 (response.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 静态分析
flutter analyze
```

## Architecture

### Core Components

- **`Net2`** (`lib/net_dio.dart`) — Singleton Dio wrapper. Call `Net2().config(...)` to set `baseUrl`, `extraHeaders`, and optional `errorHandler`.
- **`RequestMixin`** (`lib/request_mixin.dart`) — Mixin providing typed HTTP methods (`get`, `post`, `put`, `patch`, `delete`, `uploadFile`, `uploadFiles`, `download`, `downloadZipAndDecode`). Every request method takes a `Decoder<T>` (from `json_annotation`: `T Function(dynamic)`) to parse responses.
- **`SimpleRequestMixin`** (`lib/simple_request_mixin.dart`) — Mixin on `RequestMixin` that wraps API calls with `EasyLoading` spinner and toast error display.
- **`NetError` / `NetCode`** (`lib/response.dart`) — Error model with `@JsonSerializable()` and status code enum.

  | `NetCode` | `@JsonValue` | Meaning |
  |---|---|---|
  | `success` | 0 | OK |
  | `clientError` | 400 | Bad request / validation failure |
  | `authFail` | 401 | Token invalid — `shouldRelaunch` is true, app returns to login |
  | `conflict` | 409 | Optimistic-lock conflict; the caller **must** prompt a reload instead of silently overwriting |
  | `unknownError` | -1 | Fallback for any unmapped value (`unknownEnumValue`) |

  ⚠️ Adding a member means hand-editing **`response.g.dart` too**: this package has no `build_runner` dev-dependency, so `dart run build_runner build` is not available here. Keep the generated `_$NetCodeEnumMap` in sync by hand.

  ⚠️ The backend must always emit a `code` field. `unknownEnumValue` only rescues *unrecognised* values — a **missing** `code` still throws in `$enumDecode`. That is why every user-facing Django ViewSet has to inherit `ResponseWrapper` (see `teamo/.claude/rules/response-wrapper.md`).

### Interceptors (`lib/interceptors/`)

- **`Net2Interceptor`** (`modify.dart`) — Injects `extraHeaders`, handles timeouts, dispatches `errorHandler`.
- **`Net2LogInterceptor`** (`log.dart`) — Logs requests/responses/errors via `dart:developer`.

### Library Entry Point

`lib/net.dart` exports: `net_dio.dart`, `response.dart`, `request_mixin.dart`, `simple_request_mixin.dart`.

## Usage Pattern

Consumer classes `mixin RequestMixin` (or both `RequestMixin` and `SimpleRequestMixin`), then call typed HTTP methods with a `Decoder<T>` callback (typically `MyModel.fromJson`).
