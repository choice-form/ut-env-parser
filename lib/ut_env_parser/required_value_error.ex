defmodule UTEnvParser.RequiredValueError do
  defexception [:key, :old_name, :hint]

  @type t :: %__MODULE__{
          key: atom(),
          old_name: atom() | nil,
          hint: String.t() | nil
        }

  @impl Exception
  def message(error) do
    msg = "The value of the key #{key_name(error)} must be required"
    if error.hint, do: "#{msg}\nHint: #{error.hint}", else: msg
  end

  @spec key_name(error :: t()) :: String.t()
  defp key_name(error) do
    name = ~s["#{error.key}"]

    if error.old_name do
      ~s[#{name} (old name: "#{error.old_name}")]
    else
      name
    end
  end
end
