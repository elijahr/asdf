#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "reshim should allow prefixes of other versions" {
  run asdf install dummy 1.0.1
  run asdf install dummy 1.0

  run asdf reshim
  assert_success

  run grep "asdf-plugin: dummy 1.0.1" "$ASDF_DIR/shims/dummy"
  assert_success
  run grep 'asdf-plugin: dummy 1.0$' "$ASDF_DIR/shims/dummy"
  assert_success
}

@test "reshim command should remove shims of removed binaries" {
  run asdf install dummy 1.0
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]

  run asdf reshim dummy
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run asdf reshim dummy
  assert_success
  assert [ ! -f "$ASDF_DIR/shims/dummy" ]
}

@test "reshim should remove metadata of removed binaries" {
  run asdf install dummy 1.0
  run asdf install dummy 1.1

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run asdf reshim dummy
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]
  run grep "asdf-plugin: dummy 1.0" "$ASDF_DIR/shims/dummy"
  assert_failure
  run grep "asdf-plugin: dummy 1.1" "$ASDF_DIR/shims/dummy"
  assert_success
}

@test "reshim should not remove metadata of removed prefix versions" {
  run asdf install dummy 1.0
  run asdf install dummy 1.0.1
  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run asdf reshim dummy
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]
  run grep "asdf-plugin: dummy 1.0.1" "$ASDF_DIR/shims/dummy"
  assert_success
}

@test "reshim should not duplicate shims" {
  cd $PROJECT_DIR

  run asdf install dummy 1.0
  run asdf install dummy 1.1
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]

  run rm $ASDF_DIR/shims/*
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "0"

  run asdf reshim dummy
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "1"

  run asdf reshim dummy
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "1"
}

@test "reshim should create shims only for files and not folders" {
  cd $PROJECT_DIR

  run asdf install dummy 1.0
  run asdf install dummy 1.1
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]
  assert [ ! -f "$ASDF_DIR/shims/subdir" ]

  run rm $ASDF_DIR/shims/*
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "0"
  assert_equal "$(ls $ASDF_DIR/shims/subdir* | wc -l)" "0"

  run asdf reshim dummy
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "1"
  assert_equal "$(ls $ASDF_DIR/shims/subdir* | wc -l)" "0"

}

@test "reshim without arguments reshims all installed plugins" {
  run asdf install dummy 1.0
  run rm $ASDF_DIR/shims/*
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "0"
  run asdf reshim
  assert_success
  assert_equal "$(ls $ASDF_DIR/shims/dummy* | wc -l)" "1"
}

@test "reshim command executes configured pre hook" {
  run asdf install dummy 1.0

  cat >$HOME/.asdfrc <<-'EOM'
pre_asdf_reshim_dummy = echo RESHIM
EOM

  run asdf reshim dummy 1.0
  assert_output "RESHIM"
}

@test "reshim command executes configured post hook" {
  run asdf install dummy 1.0

  cat >$HOME/.asdfrc <<-'EOM'
post_asdf_reshim_dummy = echo RESHIM
EOM

  run asdf reshim dummy 1.0
  assert_output "RESHIM"
}
