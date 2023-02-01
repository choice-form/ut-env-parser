defmodule UTEnvParser.RequiredValueError do
  defexception [:key]

  @type t :: %__MODULE__{key: atom()}

  @impl Exception
  def message(error) do
    "The value of the key \"#{error.key}\" must be required"
  end
end
