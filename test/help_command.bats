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
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "help should show dummy plugin help" {
  cd $PROJECT_DIR

  run asdf help "dummy"

  expected_output="$(
    cat <<EOF
Dummy plugin documentation

Dummy plugin is a plugin only used for unit tests
EOF
  )"
  assert_success
  assert_output "$expected_output"
}

@test "help should show dummy plugin help specific to version when version is present" {
  cd $PROJECT_DIR

  run asdf help "dummy" "1.2.3"

  expected_output="$(
    cat <<EOF
Dummy plugin documentation

Dummy plugin is a plugin only used for unit tests

Details specific for version 1.2.3
EOF
  )"
  assert_success
  echo $output
  assert_output "$expected_output"
}

@test "help should fail for unknown plugins" {
  cd $PROJECT_DIR

  run asdf help "sunny"
  assert_failure
  assert_output "No plugin named sunny"
}

@test "help should fail when plugin doesn't have documentation callback" {
  cd $PROJECT_DIR

  run asdf help "legacy-dummy"
  assert_failure
  assert_output "No documentation for plugin legacy-dummy"
}

@test "help should show asdf help when no plugin name is provided" {
  cd $PROJECT_DIR

  run asdf help

  assert_success
  # TODO: Assert asdf help output is printed
}
