defmodule UTEnvParser.RequiredValueErrorTest do
  use ExUnit.Case, async: true

  alias UTEnvParser.RequiredValueError

  describe "message/1" do
    test "with key" do
      assert RequiredValueError.message(%RequiredValueError{key: :key}) ==
               ~s[The value of the key "key" must be required]
    end

    test "with key and old_name" do
      assert RequiredValueError.message(%RequiredValueError{key: :key, old_name: :old_key}) ==
               ~s[The value of the key "key" (old name: "old_key") must be required]
    end

    test "with hint" do
      assert RequiredValueError.message(%RequiredValueError{key: :key, hint: "you can xxx"}) ==
               ~s[The value of the key "key" must be required] <>
                 "\nHint: you can xxx"
    end
  end
end
