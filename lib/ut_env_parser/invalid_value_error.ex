defmodule UTEnvParser.InvalidValueError do
  use TypeCheck

  defexception [:type, :key, :value]

  @type! t :: %__MODULE__{type: atom() | {:array, atom()}, key: atom(), value: String.t() | nil}

  @impl Exception
  def message(error) do
    "The value is invalid." <>
      "type: #{inspect(error.type)}," <>
      "key: #{inspect(error.key)}," <>
      "actual value: #{inspect(error.value)}"
  end
end
