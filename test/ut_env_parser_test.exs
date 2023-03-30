defmodule UTEnvParserTest do
  use ExUnit.Case, async: true
  doctest UTEnvParser

  alias UTEnvParser.RequiredValueError
  alias UTEnvParser.InvalidValueError

  describe "parse/2 with multiple opts" do
    test "success" do
      ip_parser = fn value ->
        {:ok,
         value
         |> String.split(".")
         |> Enum.map(&String.to_integer/1)
         |> List.to_tuple()}
      end

      assert {:ok, config} =
               UTEnvParser.parse(
                 [
                   key_string: [type: :string],
                   key_integer: [type: :integer],
                   key_float: [type: :float],
                   key_number: [type: :number],
                   key_boolean: [type: :boolean],
                   key_array_of_string: [type: {:array, :string}],
                   key_ip: [type: ip_parser],
                   key_ips: [type: {:array, ip_parser}]
                 ],
                 get_env_fn: fn
                   "KEY_STRING" -> "abc"
                   "KEY_INTEGER" -> "1"
                   "KEY_FLOAT" -> "1.5"
                   "KEY_NUMBER" -> "1"
                   "KEY_BOOLEAN" -> "true"
                   "KEY_ARRAY_OF_STRING" -> "a,b,c"
                   "KEY_IP" -> "1.1.1.1"
                   "KEY_IPS" -> "1.1.1.1,2.2.2.2"
                 end
               )

      assert config == %{
               key_string: "abc",
               key_integer: 1,
               key_float: 1.5,
               key_number: 1,
               key_boolean: true,
               key_array_of_string: ~w[a b c],
               key_ip: {1, 1, 1, 1},
               key_ips: [{1, 1, 1, 1}, {2, 2, 2, 2}]
             }
    end
  end

  describe "parse/2 with string" do
    test "required" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string, required: true]],
                 get_env_fn: fn "KEY" -> "str" end
               )

      assert config == %{key: "str"}

      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :string, required: true]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert error == %RequiredValueError{key: :key}
    end

    test "no value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: nil}
    end

    test "no value with default" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string, default: "abc"]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: "abc"}
    end

    test "valid value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string]],
                 get_env_fn: fn "KEY" -> "str" end
               )

      assert config == %{key: "str"}
    end
  end

  describe "parse/2 with integer" do
    test "required" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :integer, required: true]],
                 get_env_fn: fn "KEY" -> "1" end
               )

      assert config == %{key: 1}

      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :integer, required: true]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert error == %RequiredValueError{key: :key}
    end

    test "no value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :integer]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: nil}
    end

    test "no value with default" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :integer, default: 1]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: 1}
    end

    test "valid value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :integer]],
                 get_env_fn: fn "KEY" -> "1" end
               )

      assert config == %{key: 1}
    end

    test "invalid value" do
      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :integer]],
                 get_env_fn: fn "KEY" -> "abc" end
               )

      assert error == %InvalidValueError{type: :integer, key: :key, value: "abc"}
    end
  end

  describe "parse/2 with float" do
    test "required" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :float, required: true]],
                 get_env_fn: fn "KEY" -> "1.5" end
               )

      assert config == %{key: 1.5}

      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :float, required: true]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert error == %RequiredValueError{key: :key}
    end

    test "no value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :float]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: nil}
    end

    test "no value with default" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :float, default: 1.5]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: 1.5}
    end

    test "valid value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :float]],
                 get_env_fn: fn "KEY" -> "1.5" end
               )

      assert config == %{key: 1.5}

      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :float]],
                 get_env_fn: fn "KEY" -> "1" end
               )

      assert config == %{key: 1.0}
    end

    test "invalid value" do
      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :float]],
                 get_env_fn: fn "KEY" -> "abc" end
               )

      assert error == %InvalidValueError{type: :float, key: :key, value: "abc"}
    end
  end

  describe "parse/2 with number" do
    test "required" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :number, required: true]],
                 get_env_fn: fn "KEY" -> "1.5" end
               )

      assert config == %{key: 1.5}

      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :number, required: true]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert error == %RequiredValueError{key: :key}
    end

    test "no value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :number]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: nil}
    end

    test "no value with default" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :number, default: 1.5]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: 1.5}
    end

    test "valid value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :number]],
                 get_env_fn: fn "KEY" -> "1" end
               )

      assert config == %{key: 1}

      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :number]],
                 get_env_fn: fn "KEY" -> "1.5" end
               )

      assert config == %{key: 1.5}
    end

    test "invalid value" do
      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :number]],
                 get_env_fn: fn "KEY" -> "abc" end
               )

      assert error == %InvalidValueError{type: :number, key: :key, value: "abc"}
    end
  end

  describe "parse/2 with boolean" do
    test "required" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :boolean, required: true]],
                 get_env_fn: fn "KEY" -> "true" end
               )

      assert config == %{key: true}

      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :number, required: true]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert error == %RequiredValueError{key: :key}
    end

    test "no value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :boolean]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: nil}
    end

    test "no value with default" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :boolean, default: false]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: false}
    end

    test "valid value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :boolean]],
                 get_env_fn: fn "KEY" -> "true" end
               )

      assert config == %{key: true}

      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :boolean]],
                 get_env_fn: fn "KEY" -> "false" end
               )

      assert config == %{key: false}
    end

    test "invalid value" do
      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: :boolean]],
                 get_env_fn: fn "KEY" -> "abc" end
               )

      assert error == %InvalidValueError{type: :boolean, key: :key, value: "abc"}
    end
  end

  describe "parse/2 with old_name" do
    test "success" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string, old_name: :old_key]],
                 get_env_fn: fn
                   "KEY" -> "abc"
                 end
               )

      assert config == %{key: "abc"}

      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string, old_name: :old_key]],
                 get_env_fn: fn
                   "KEY" -> "abc"
                   "OLD_KEY" -> "old abc"
                 end
               )

      assert config == %{key: "abc"}

      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: :string, old_name: :old_key]],
                 get_env_fn: fn
                   "KEY" -> nil
                   "OLD_KEY" -> "old abc"
                 end
               )

      assert config == %{key: "old abc"}
    end
  end

  describe "parse/2 with function" do
    test "required" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: fn value -> {:ok, String.to_integer(value)} end, required: true]],
                 get_env_fn: fn "KEY" -> "1" end
               )

      assert config == %{key: 1}

      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: fn value -> {:ok, String.to_integer(value)} end, required: true]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert error == %RequiredValueError{key: :key}
    end

    test "no value" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: fn value -> {:ok, String.to_integer(value)} end]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: nil}
    end

    test "no value with default" do
      assert {:ok, config} =
               UTEnvParser.parse(
                 [key: [type: fn value -> {:ok, String.to_integer(value)} end, default: 1]],
                 get_env_fn: fn "KEY" -> nil end
               )

      assert config == %{key: 1}
    end

    test "invalid value" do
      assert {:error, error} =
               UTEnvParser.parse(
                 [key: [type: fn value -> {:ok, String.to_integer(value)} end]],
                 get_env_fn: fn "KEY" -> "not a number" end
               )

      assert error == %InvalidValueError{type: :custom_parser, key: :key, value: "not a number"}
    end
  end
end
