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

@test "plugin_remove_command removes a plugin" {
  install_dummy_plugin

  run asdf plugin-remove "dummy"
  assert_success
  assert_output "plugin-remove ${ASDF_DIR}/plugins/dummy"
}

@test "plugin_remove_command should exit with 1 when not passed any arguments" {
  run asdf plugin-remove
  assert_failure
  assert_output "No plugin given"
}

@test "plugin_remove_command should exit with 1 when passed invalid plugin name" {
  run asdf plugin-remove "does-not-exist"
  assert_failure
  assert_output "No such plugin: does-not-exist"
}

@test "plugin_remove_command should remove installed versions" {
  install_dummy_plugin
  run asdf install dummy 1.0
  assert_success
  assert [ -d "$ASDF_DIR"/installs/dummy ]

  run asdf plugin-remove dummy
  assert_success
  assert [ ! -d "$ASDF_DIR"/installs/dummy ]
}

@test "plugin_remove_command should also remove shims for that plugin" {
  install_dummy_plugin
  run asdf install dummy 1.0
  assert_success
  assert [ -f "$ASDF_DIR"/shims/dummy ]

  run asdf plugin-remove dummy
  assert_success
  assert [ ! -f "$ASDF_DIR"/shims/dummy ]
}

@test "plugin_remove_command should not remove unrelated shims" {
  install_dummy_plugin
  run asdf install dummy 1.0

  # make an unrelated shim
  echo "# asdf-plugin: gummy" >"$ASDF_DIR"/shims/gummy

  run asdf plugin-remove dummy
  assert_success

  # unrelated shim should exist
  assert [ -f "$ASDF_DIR"/shims/gummy ]
}

@test "plugin_remove_command executes pre-plugin-remove script" {
  install_dummy_plugin

  run asdf plugin-remove dummy

  assert_output "plugin-remove ${ASDF_DIR}/plugins/dummy"
}

@test "plugin_remove_command executes configured pre hook (generic)" {
  install_dummy_plugin

  cat >"$HOME"/.asdfrc <<-'EOM'
pre_asdf_plugin_remove = echo REMOVE ${@}
EOM

  run asdf plugin-remove dummy

  local expected_output="REMOVE dummy
plugin-remove ${ASDF_DIR}/plugins/dummy"
  assert_output "$expected_output"
}

@test "plugin_remove_command executes configured pre hook (specific)" {
  install_dummy_plugin

  cat >"$HOME"/.asdfrc <<-'EOM'
pre_asdf_plugin_remove_dummy = echo REMOVE
EOM

  run asdf plugin-remove dummy

  local expected_output="REMOVE
plugin-remove ${ASDF_DIR}/plugins/dummy"
  assert_output "$expected_output"
}

@test "plugin_remove_command executes configured post hook (generic)" {
  install_dummy_plugin

  cat >"$HOME"/.asdfrc <<-'EOM'
post_asdf_plugin_remove = echo REMOVE ${@}
EOM

  run asdf plugin-remove dummy

  local expected_output="plugin-remove ${ASDF_DIR}/plugins/dummy
REMOVE dummy"
  assert_output "$expected_output"
}

@test "plugin_remove_command executes configured post hook (specific)" {
  install_dummy_plugin

  cat >"$HOME"/.asdfrc <<-'EOM'
post_asdf_plugin_remove_dummy = echo REMOVE
EOM

  run asdf plugin-remove dummy

  local expected_output="plugin-remove ${ASDF_DIR}/plugins/dummy
REMOVE"
  assert_output "$expected_output"
}
