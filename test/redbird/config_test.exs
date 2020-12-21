defmodule Redbird.ConfigTest do
  use ExUnit.Case, async: true

  setup do
    on_exit(fn ->
      Application.put_env(:redbird, :redis_options, [])
    end)
  end

  describe "redis_options" do
    test "returns an empty list by default" do
      assert [] == Redbird.Config.redis_options()
    end

    test "returns application config's redis_options" do
      Application.put_env(:redbird, :redis_options, host: "localhost")

      redis_options = Redbird.Config.redis_options()

      assert [host: "localhost"] == redis_options
    end

    test "returns url tuple if url is present" do
      options = [url: "rediss://localhost:3400", host: "localhost"]
      Application.put_env(:redbird, :redis_options, options)

      {url, opts} = Redbird.Config.redis_options()

      assert url == options[:url]
      assert opts == [host: "localhost"]
    end

    test "allows options to be passed" do
      redis_options = Redbird.Config.redis_options(name: :redis)

      assert [name: :redis] == redis_options
    end
  end
end
