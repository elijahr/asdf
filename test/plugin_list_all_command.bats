#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  setup_repo
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "plugin_list_all list all plugins in the repository" {
  run asdf plugin-list-all
  local expected="\
bar                           http://example.com/bar
dummy                        *http://example.com/dummy
foo                           http://example.com/foo"
  assert_success
  assert_output "$expected"
}
