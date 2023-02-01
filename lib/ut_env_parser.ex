defmodule UTEnvParser do
  @moduledoc """
  环境变量的解析器

  用于配合项目的 config/runtime.exs ，读取并标准化环境变量的值。

  ## Examples

      iex> UTEnvParser.parse!(
      ...>   [
      ...>     key_string: [type: :string],
      ...>     key_integer: [type: :integer],
      ...>     key_float: [type: :float],
      ...>     key_number: [type: :number],
      ...>     key_boolean: [type: :boolean],
      ...>     key_array_of_string: [type: {:array, :string}]
      ...>   ],
      ...>   # 模拟环境变量获取的函数，正式使用时默认值是 `System.get_env/1`
      ...>   get_env_fn: fn
      ...>     "KEY_STRING" -> "abc"
      ...>     "KEY_INTEGER" -> "1"
      ...>     "KEY_FLOAT" -> "1.5"
      ...>     "KEY_NUMBER" -> "1"
      ...>     "KEY_BOOLEAN" -> "true"
      ...>     "KEY_ARRAY_OF_STRING" -> "a,b,c"
      ...>   end
      ...> )
      %{
        key_string: "abc",
        key_integer: 1,
        key_float: 1.5,
        key_number: 1,
        key_boolean: true,
        key_array_of_string: ~w[a b c]
      }

  """

  alias UTEnvParser.{
    KeyOpts,
    RequiredValueError,
    InvalidValueError
  }

  @type config :: %{optional(atom()) => any()}

  @type value :: String.t() | number() | boolean() | [String.t()] | nil

  @type error :: RequiredValueError.t() | InvalidValueError.t()

  @doc """
  定义规则并解析环境变量

  如果解析成功会返回 `{:ok, config}` ，失败会返回 `{:error, error}` 。
  """
  @spec parse(schema :: keyword(), opts :: keyword()) :: {:ok, config()} | {:error, error()}
  def parse(schema, opts \\ []) do
    {:ok, parse!(schema, opts)}
  rescue
    err in [RequiredValueError, InvalidValueError] ->
      {:error, err}
  end

  @doc """
  定义规则并解析环境变量

  如果解析过程出错就会抛出异常。
  """
  @spec parse!(schema :: keyword(), opts :: keyword()) :: config()
  def parse!(schema, opts \\ []) do
    default_opts = [get_env_fn: &System.get_env/1]
    opts = Keyword.merge(default_opts, opts)

    schema
    |> Enum.map(fn {key, opts} ->
      [name: key] |> Keyword.merge(opts) |> KeyOpts.new()
    end)
    |> Enum.reduce(%{}, fn key_opts, config ->
      Map.put(config, key_opts.name, load_and_parse!(key_opts, opts))
    end)
  end

  @spec load_and_parse!(key_opts :: KeyOpts.t(), opts :: keyword()) :: value() | no_return()
  defp load_and_parse!(key_opts, opts) do
    raw_value = load_raw_value(key_opts, opts)

    if raw_value == nil do
      if key_opts.required do
        raise_required_value_error(key_opts)
      else
        key_opts.default
      end
    else
      parse_value!(key_opts, raw_value)
    end
  end

  defp load_raw_value(key_opts, opts) do
    case opts[:get_env_fn].(env_name(key_opts.name)) do
      nil ->
        if key_opts.old_name do
          opts[:get_env_fn].(env_name(key_opts.old_name))
        else
          nil
        end

      val ->
        val
    end
  end

  defp parse_value!(%KeyOpts{type: :string}, raw) do
    raw
  end

  defp parse_value!(%KeyOpts{type: :integer} = key_opts, raw) do
    case Integer.parse(raw) do
      {val, ""} -> val
      _ -> raise_invalid_value_error(key_opts, raw)
    end
  end

  defp parse_value!(%KeyOpts{type: :float} = key_opts, raw) do
    case Float.parse(raw) do
      {val, ""} -> val
      _ -> raise_invalid_value_error(key_opts, raw)
    end
  end

  defp parse_value!(%KeyOpts{type: :number} = key_opts, raw) do
    case Integer.parse(raw) do
      {val, ""} ->
        val

      {_, _} ->
        case Float.parse(raw) do
          {val, ""} -> val
          true -> raise_invalid_value_error(key_opts, raw)
        end

      :error ->
        raise_invalid_value_error(key_opts, raw)
    end
  end

  defp parse_value!(%KeyOpts{type: :boolean} = key_opts, raw) do
    case raw do
      "true" -> true
      "false" -> false
      _ -> raise_invalid_value_error(key_opts, raw)
    end
  end

  defp parse_value!(%KeyOpts{type: {:array, :string}} = key_opts, raw) do
    String.split(raw, key_opts.splitter)
  end

  @spec env_name(key :: atom()) :: String.t()
  defp env_name(key) do
    key
    |> Atom.to_string()
    |> String.replace(~r/\?$/, "")
    |> String.upcase()
  end

  defp raise_required_value_error(key_opts) do
    raise RequiredValueError, key: key_opts.name
  end

  defp raise_invalid_value_error(key_opts, raw) do
    raise InvalidValueError, type: key_opts.type, key: key_opts.name, value: raw
  end
end
