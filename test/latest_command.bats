#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "latest_command shows latest stable version" {
  run asdf latest dummy
  assert_equal "$(echo -e "2.0.0")" "$output"
  assert_success
}

@test "latest_command with version shows latest stable version that matches the given string" {
  run asdf latest dummy 1
  assert_equal "$(echo -e "1.1.0")" "$output"
  assert_success
}
