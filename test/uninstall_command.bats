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

@test "uninstall_command should fail when no such version is installed" {
  run asdf uninstall dummy 3.14
  assert_output "No such version"
  assert_failure
}

@test "uninstall_command should remove the plugin with that version from asdf" {
  run asdf install dummy 1.1.0
  assert_success
  assert [ $(cat $ASDF_DIR/installs/dummy/1.1.0/version) = "1.1.0" ]
  run asdf uninstall dummy 1.1.0
  assert [ ! -f $ASDF_DIR/installs/dummy/1.1.0/version ]
}

@test "uninstall_command should invoke the plugin bin/uninstall if available" {
  run asdf install dummy 1.1.0
  assert_success
  mkdir -p $ASDF_DIR/plugins/dummy/bin
  echo "echo custom uninstall" >$ASDF_DIR/plugins/dummy/bin/uninstall
  chmod 755 $ASDF_DIR/plugins/dummy/bin/uninstall
  run asdf uninstall dummy 1.1.0
  assert_output "custom uninstall"
  assert_success
}

@test "uninstall_command should remove the plugin shims if no other version is installed" {
  run asdf install dummy 1.1.0
  assert [ -f $ASDF_DIR/shims/dummy ]
  run asdf uninstall dummy 1.1.0
  assert [ ! -f $ASDF_DIR/shims/dummy ]
}

@test "uninstall_command should leave the plugin shims if other version is installed" {
  run asdf install dummy 1.0.0
  assert [ -f $ASDF_DIR/installs/dummy/1.0.0/bin/dummy ]

  run asdf install dummy 1.1.0
  assert [ -f $ASDF_DIR/installs/dummy/1.1.0/bin/dummy ]

  assert [ -f $ASDF_DIR/shims/dummy ]
  run asdf uninstall dummy 1.0.0
  assert [ -f $ASDF_DIR/shims/dummy ]
}

@test "uninstall_command should remove relevant asdf-plugin metadata" {
  run asdf install dummy 1.0.0
  assert [ -f $ASDF_DIR/installs/dummy/1.0.0/bin/dummy ]

  run asdf install dummy 1.1.0
  assert [ -f $ASDF_DIR/installs/dummy/1.1.0/bin/dummy ]

  run asdf uninstall dummy 1.0.0
  run grep "asdf-plugin: dummy 1.1.0" $ASDF_DIR/shims/dummy
  assert_success
  run grep "asdf-plugin: dummy 1.0.0" $ASDF_DIR/shims/dummy
  assert_failure
}

@test "uninstall_command should not remove other unrelated shims" {
  run asdf install dummy 1.0.0
  assert [ -f $ASDF_DIR/shims/dummy ]

  touch $ASDF_DIR/shims/gummy
  assert [ -f $ASDF_DIR/shims/gummy ]

  run asdf uninstall dummy 1.0.0
  assert [ -f $ASDF_DIR/shims/gummy ]
}

@test "uninstall command executes configured pre hook" {
  cat >$HOME/.asdfrc <<-'EOM'
pre_asdf_uninstall_dummy = echo will uninstall dummy $1
EOM

  run asdf install dummy 1.0.0
  run asdf uninstall dummy 1.0.0
  assert_output "will uninstall dummy 1.0.0"
}

@test "uninstall command executes configured post hook" {
  cat >$HOME/.asdfrc <<-'EOM'
post_asdf_uninstall_dummy = echo removed dummy $1
EOM

  run asdf install dummy 1.0.0
  run asdf uninstall dummy 1.0.0
  echo $output
  assert_output "removed dummy 1.0.0"
}
