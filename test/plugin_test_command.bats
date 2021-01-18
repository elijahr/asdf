#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_test_command with no URL specified prints an error" {
  run asdf plugin-test "elixir"
  assert_failure
  assert_output "FAILED: please provide a plugin name and url"
}

@test "plugin_test_command with no name or URL specified prints an error" {
  run asdf plugin-test
  assert_failure
  assert_output "FAILED: please provide a plugin name and url"
}
