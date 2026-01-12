# UtEnvParser

环境变量的解析器，用于配合项目的 `config/runtime.exs`，读取并标准化环境变量的值。

## 功能特性

- 支持多种数据类型：字符串、整数、浮点数、数字、布尔值、数组、自定义类型
- 自动类型转换和验证
- 支持必填项和默认值
- 支持旧配置名称迁移（`old_name`）
- 自定义分隔符（用于数组类型）
- 友好的错误提示（`hint`）
- 可自定义环境变量获取函数（用于测试）

## 安装

在项目的 `mix.exs` 中：

```elixir
def deps do
  [
    # 建议指定 tag 而不是直接使用 develop 或 main 分支
    {:ut_env_parser, git: "git@github.com:choice-form/ut-env-parser.git", tag: "v0.1.0"},
  ]
end
```

## 使用方法

### 基本用法

```elixir
# 在 config/runtime.exs 中
import Config

config :my_app, MyApp.Config,
  env_config:
    UtEnvParser.parse!([
      port: [type: :integer, required: true],
      host: [type: :string, default: "localhost"],
      debug: [type: :boolean, default: false],
      timeout: [type: :number, default: 5000]
    ])
```

### 支持的数据类型

#### 字符串 (`:string`)

```elixir
UtEnvParser.parse!([
  api_key: [type: :string, required: true]
])
```

#### 整数 (`:integer`)

```elixir
UtEnvParser.parse!([
  port: [type: :integer, default: 4000]
])
```

#### 浮点数 (`:float`)

```elixir
UtEnvParser.parse!([
  rate: [type: :float, default: 0.5]
])
```

#### 数字 (`:number`)

自动识别整数或浮点数：

```elixir
UtEnvParser.parse!([
  timeout: [type: :number, default: 5000]
])
```

#### 布尔值 (`:boolean`)

只接受 `"true"` 或 `"false"`：

```elixir
UtEnvParser.parse!([
  debug: [type: :boolean, default: false]
])
```

#### 字符串数组 (`{:array, :string}`)

默认使用逗号分隔（支持正则表达式）：

```elixir
UtEnvParser.parse!([
  allowed_hosts: [type: {:array, :string}, splitter: ~r/\s*,\s*/]
])
```

环境变量示例：`ALLOWED_HOSTS=example.com,test.com,localhost`

#### 自定义解析器

使用函数进行自定义解析：

```elixir
ip_parser = fn value ->
  {:ok,
   value
   |> String.split(".")
   |> Enum.map(&String.to_integer/1)
   |> List.to_tuple()}
end

UtEnvParser.parse!([
  ip: [type: ip_parser],
  ips: [type: {:array, ip_parser}]
])
```

### 配置选项

- `type` - 数据类型（必需）
- `required` - 是否必填，默认 `false`
- `default` - 默认值
- `old_name` - 旧配置名称，用于无缝迁移
- `splitter` - 数组分隔符（字符串或正则表达式），默认 `~r/\s*,\s*/`
- `hint` - 错误提示信息

### 错误处理

使用 `parse/2` 返回 `{:ok, config}` 或 `{:error, error}`：

```elixir
case UtEnvParser.parse([port: [type: :integer, required: true]]) do
  {:ok, config} -> config
  {:error, %UtEnvParser.RequiredValueError{}} -> # 处理错误
  {:error, %UtEnvParser.InvalidValueError{}} -> # 处理错误
end
```

使用 `parse!/2` 会在出错时抛出异常：

```elixir
config = UtEnvParser.parse!([port: [type: :integer, required: true]])
```

### 旧配置名称迁移

支持通过 `old_name` 选项实现配置名称的无缝迁移：

```elixir
UtEnvParser.parse!([
  new_key: [type: :string, old_name: :old_key]
])
```

会先尝试读取 `NEW_KEY`，如果不存在则读取 `OLD_KEY`。

### 自定义环境变量获取函数

默认使用 `System.get_env/1`，可以通过 `get_env_fn` 选项自定义（常用于测试）：

```elixir
UtEnvParser.parse!(
  [port: [type: :integer]],
  get_env_fn: fn "PORT" -> "4000" end
)
```

### 环境变量命名规则

- 配置键名会自动转换为大写
- 如果键名以 `?` 结尾，会被移除（例如 `port?` 对应 `PORT`）

## API 文档

详细的 API 文档请参考 [Hex 文档](https://hexdocs.pm/ut_env_parser) 或运行 `mix docs`。

## 许可证

[待补充]
