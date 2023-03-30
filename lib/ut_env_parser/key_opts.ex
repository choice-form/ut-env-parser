defmodule UTEnvParser.KeyOpts do
  @moduledoc """
  配置项（一项环境变量）相关的选项

  具体属性参考 `UTEnvParser.KeyOpts.t()` 的文档
  """

  use TypeCheck

  defstruct [:name, :old_name, :type, :required, :default, :splitter, :hint]

  @typedoc """
  配置项的结构体

  * `name` - 配置名称
  * `old_name` - 旧配置名称，方便项目改名后无缝迁移
  * `type` - 类型，见 `type()`
  * `required` - 是否必填，有无 `default` 不影响，默认值 `false`
  * `default` - 默认值
  * `splitter` - 分隔符，仅对 `{:array, :string}` 类型使用
  * `hint` - 错误提示
  """
  @type! t :: %__MODULE__{
           name: atom(),
           old_name: atom() | nil,
           type: type(),
           required: boolean(),
           default: any() | nil,
           splitter: String.t() | Regex.t() | nil,
           hint: String.t() | nil
         }

  @type! type ::
           :integer
           | :float
           | :number
           | :boolean
           | :string
           | {:array, :string}
           | function()
           | {:array, function()}

  @spec! new(opts :: keyword()) :: t()
  def new(opts) do
    default_opts = [required: false]

    struct!(__MODULE__, Keyword.merge(default_opts, opts))
    |> add_type_specific_default_opts()
  end

  defp add_type_specific_default_opts(%__MODULE__{type: {:array, _}} = key_opts) do
    %{key_opts | splitter: key_opts.splitter || ~r/\s*,\s*/}
  end

  defp add_type_specific_default_opts(key_opts), do: key_opts
end
