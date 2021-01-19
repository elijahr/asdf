#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_legacy_plugin
  run asdf install dummy 1.0
  run asdf install dummy 1.1

  PROJECT_DIR=$HOME/project
  mkdir "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "info should show os, shell and asdf debug information" {
  cd "$PROJECT_DIR"

  run asdf info

  assert_success
  # TODO: Assert asdf info output is printed
}
