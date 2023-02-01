defmodule UTEnvParser.KeyOpts do
  alias UTEnvParser.KeyOptsError

  defstruct [:name, :old_name, :type, :required, :default, :splitter, :hint]

  @type t :: %__MODULE__{
          name: atom(),
          old_name: atom() | nil,
          type: type(),
          required: boolean(),
          default: any() | nil,
          splitter: String.t() | Regex.t() | nil,
          hint: String.t() | nil
        }

  @type type :: :integer | :float | :number | :boolean | :string | {:array, :string}

  @spec new(opts :: keyword()) :: t()
  def new(opts) do
    default_opts = [required: false]

    struct!(__MODULE__, Keyword.merge(default_opts, opts))
    |> add_type_specific_default_opts()
    |> validate_type!()
    |> validate_required!()
  end

  defp add_type_specific_default_opts(%__MODULE__{type: {:array, :string}} = key_opts) do
    %{key_opts | splitter: key_opts.splitter || ~r/\s*,\s*/}
  end

  defp add_type_specific_default_opts(key_opts), do: key_opts

  defp validate_type!(%__MODULE__{type: type} = key_opts) do
    if type in [:integer, :float, :number, :boolean, :string, {:array, :string}] do
      key_opts
    else
      raise KeyOptsError, "\"type\" is invalid, got #{inspect(type)}"
    end
  end

  defp validate_required!(%__MODULE__{required: required} = key_opts) do
    if is_boolean(required) do
      key_opts
    else
      raise KeyOptsError, "\"required\" must be boolean, got #{inspect(required)}"
    end
  end
end
