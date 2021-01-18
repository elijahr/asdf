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

@test "plugin_remove command removes the plugin directory" {
  run asdf install dummy 1.0
  assert_success
  assert [ -d "$ASDF_DIR/downloads/dummy" ]

  run asdf plugin-remove "dummy"
  assert_success
  assert [ ! -d "$ASDF_DIR/downloads/dummy" ]
}

@test "plugin_remove command fails if the plugin doesn't exist" {
  run asdf plugin-remove "does-not-exist"
  assert_failure
  echo "$output" | grep "No such plugin: does-not-exist"
}
