#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR
  cd $PROJECT_DIR

  # asdf lib needed to run generated shims
  cp -rf $BATS_TEST_DIRNAME/../{bin,lib} $ASDF_DIR/
}

teardown() {
  clean_asdf_dir
}

@test "asdf env without argument should display help" {
  run asdf env
  assert_failure
  echo "$output" | grep "usage: asdf env <command>"
}

@test "asdf env should execute under the environment used for a shim" {
  echo "dummy 1.0" >$PROJECT_DIR/.tool-versions
  run asdf install

  run asdf env dummy which dummy
  assert_success
  assert_output "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
}

@test "asdf env should execute under plugin custom environment used for a shim" {
  echo "dummy 1.0" >$PROJECT_DIR/.tool-versions
  run asdf install

  echo "export FOO=bar" >$ASDF_DIR/plugins/dummy/bin/exec-env
  chmod +x $ASDF_DIR/plugins/dummy/bin/exec-env

  run asdf env dummy
  assert_success
  echo $output | grep 'FOO=bar'
}

@test "asdf env should ignore plugin custom environment on system version" {
  echo "dummy 1.0" >$PROJECT_DIR/.tool-versions
  run asdf install

  echo "export FOO=bar" >$ASDF_DIR/plugins/dummy/bin/exec-env
  chmod +x $ASDF_DIR/plugins/dummy/bin/exec-env

  echo "dummy system" >$PROJECT_DIR/.tool-versions

  run asdf env dummy
  assert_success

  run grep 'FOO=bar' <(echo $output)
  assert_output ""
  assert_failure

  run asdf env dummy which dummy
  assert_output "$ASDF_DIR/shims/dummy"
  assert_success
}

@test "asdf env should set PATH correctly" {
  echo "dummy 1.0" >$PROJECT_DIR/.tool-versions
  run asdf install

  run asdf env dummy
  assert_success

  # Should set path
  path_line=$(echo "$output" | grep '^PATH=')
  assert [ "$path_line" != "" ]

  # Should not contain duplicate colon
  run grep '::' <(echo "$path_line")
  assert_equal "$duplicate_colon" ""
}
