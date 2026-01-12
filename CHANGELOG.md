# Changelog

所有重要的变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [0.4.0] - 2025-01-12

### 新增

- 初始版本发布
- 支持基本数据类型：`:string`、`:integer`、`:float`、`:number`、`:boolean`
- 支持字符串数组类型：`{:array, :string}`
- 支持自定义解析器函数
- 支持自定义解析器数组：`{:array, function()}`
- 支持必填项验证（`required: true`）
- 支持默认值（`default`）
- 支持旧配置名称迁移（`old_name`）
- 支持自定义数组分隔符（`splitter`）
- 支持错误提示信息（`hint`）
- 提供 `parse/2` 和 `parse!/2` 两个解析函数
- 自动将配置键名转换为大写环境变量名
- 支持以 `?` 结尾的键名（自动移除）
- 自定义环境变量获取函数（`get_env_fn` 选项）
- 完善的错误类型：`RequiredValueError` 和 `InvalidValueError`

### 变更

- 模块名从 `UTEnvParser` 重命名为 `UtEnvParser`（遵循 Elixir 命名规范）
