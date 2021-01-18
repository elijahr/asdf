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

@test "list_command should list plugins with installed versions" {
  run asdf install dummy 1.0.0
  run asdf install dummy 1.1.0
  run asdf list
  assert_equal "$(echo -e "dummy\n  1.0.0\n  1.1.0")" "$output"
  assert_success
}

@test "list_command should continue listing even when no version is installed for any of the plugins" {
  run install_mock_plugin "dummy"
  run install_mock_plugin "mummy"
  run install_mock_plugin "tummy"
  run asdf install dummy 1.0.0
  run asdf install tummy 2.0.0
  run asdf list
  assert_equal "$(echo -e "dummy\n  1.0.0\nmummy\n  No versions installed\ntummy\n  2.0.0")" "$output"
  assert_success
}

@test "list_command with plugin should list installed versions" {
  run asdf install dummy 1.0.0
  run asdf install dummy 1.1.0
  run asdf list dummy
  assert_equal "$(echo -e "  1.0.0\n  1.1.0")" "$output"
  assert_success
}

@test "list_all_command lists available versions" {
  run asdf list-all dummy
  assert_equal "$(echo -e "1.0.0\n1.1.0\n2.0.0")" "$output"
  assert_success
}

@test "list_all_command with version filters available versions" {
  run asdf list-all dummy 1
  assert_equal "$(echo -e "1.0.0\n1.1.0")" "$output"
  assert_success
}
