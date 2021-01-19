#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_legacy_plugin
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir "$PROJECT_DIR"
}

teardown() {
  clean_asdf_dir
}

@test "install_command installs the correct version" {
  run asdf install dummy 1.1.0
  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.1.0/version)" "1.1.0"
}

@test "install_command installs the correct version for plugins without download script" {
  run asdf install legacy-dummy 1.1.0
  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/legacy-dummy/1.1.0/version)" "1.1.0"
}

@test "install_command without arguments installs even if the user is terrible and does not use newlines" {
  cd "$PROJECT_DIR"
  echo -n 'dummy 1.2.0' >".tool-versions"
  run asdf install
  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.2.0/version)" "1.2.0"
}

@test "install_command with only name installs the version in .tool-versions" {
  cd "$PROJECT_DIR"
  echo -n 'dummy 1.2.0' >".tool-versions"
  run asdf install dummy
  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.2.0/version)" "1.2.0"
}

@test "install_command set ASDF_CONCURRENCY" {
  run asdf install dummy 1.0.0
  assert_success
  assert [ -f "$ASDF_DIR"/installs/dummy/1.0.0/env ]
  run grep ASDF_CONCURRENCY "$ASDF_DIR"/installs/dummy/1.0.0/env
  assert_success
}

@test "install_command without arguments should work in directory containing whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"
  echo 'dummy 1.2.0' >>"$WHITESPACE_DIR/.tool-versions"

  run asdf install

  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.2.0/version)" "1.2.0"
}

@test "install_command should create a shim with asdf-plugin metadata" {
  run asdf install dummy 1.0.0
  assert_success
  assert [ -f "$ASDF_DIR"/installs/dummy/1.0.0/env ]
  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR"/shims/dummy
  assert_success
}

@test "install_command should create a shim with asdf-plugin metadata for plugins without download script" {
  run asdf install legacy-dummy 1.0.0
  assert_success
  assert [ -f "$ASDF_DIR"/installs/legacy-dummy/1.0.0/env ]
  run grep "asdf-plugin: legacy-dummy 1.0.0" "$ASDF_DIR"/shims/dummy
  assert_success
}

@test "install_command on two versions should create a shim with asdf-plugin metadata" {
  run asdf install dummy 1.1.0
  assert_success

  run grep "asdf-plugin: dummy 1.1.0" "$ASDF_DIR"/shims/dummy
  assert_success

  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR"/shims/dummy
  assert_failure

  run asdf install dummy 1.0.0
  assert_success
  run grep "asdf-plugin: dummy 1.0.0" "$ASDF_DIR"/shims/dummy
  assert_success

  run grep "# asdf-plugin: dummy 1.0.0"$'\n'"# asdf-plugin: dummy 1.1.0" "$ASDF_DIR"/shims/dummy
  assert_success

  lines_count=$(grep -c "asdf-plugin: dummy 1.1.0" "$ASDF_DIR"/shims/dummy)
  assert_equal "$lines_count" "1"
}

@test "install_command without arguments should not generate shim for subdir" {
  cd "$PROJECT_DIR"
  echo 'dummy 1.0.0' >"$PROJECT_DIR"/.tool-versions

  run asdf install
  assert_success
  assert [ -f "$ASDF_DIR/shims/dummy" ]
  assert [ ! -f "$ASDF_DIR/shims/subdir" ]
}

@test "install_command without arguments should generate shim that passes all arguments to executable" {
  # asdf lib needed to run generated shims
  cp -rf "$BATS_TEST_DIRNAME"/../{bin,lib} "$ASDF_DIR"/

  cd "$PROJECT_DIR"
  echo 'dummy 1.0.0' >"$PROJECT_DIR"/.tool-versions
  run asdf install

  # execute the generated shim
  run "$ASDF_DIR"/shims/dummy world hello
  assert_success
  assert_output "This is Dummy 1.0.0! hello world"
}

@test "install_command fails when tool is specified but no version of the tool is configured" {
  run asdf install dummy
  assert_failure
  assert_output "No versions specified for dummy in config files or environment"
  assert [ ! -f "$ASDF_DIR"/installs/dummy/1.1.0/version ]
}

@test "install_command fails when tool is specified but no version of the tool is configured in config file" {
  echo 'dummy 1.0.0' >"$PROJECT_DIR"/.tool-versions
  run asdf install other-dummy
  assert_failure
  assert_output "No versions specified for other-dummy in config files or environment"
  assert [ ! -f "$ASDF_DIR"/installs/dummy/1.0.0/version ]
}

@test "install_command fails when two tools are specified with no versions" {
  printf 'dummy 1.0.0\nother-dummy 2.0.0' >"$PROJECT_DIR"/.tool-versions
  run asdf install dummy other-dummy
  assert_failure
  assert_output "Dummy couldn't install version: other-dummy (on purpose)"
  assert [ ! -f "$ASDF_DIR"/installs/dummy/1.0.0/version ]
  assert [ ! -f "$ASDF_DIR"/installs/other-dummy/2.0.0/version ]
}

@test "install_command without arguments uses a parent directory .tool-versions file if present" {
  # asdf lib needed to run generated shims
  cp -rf "$BATS_TEST_DIRNAME"/../{bin,lib} "$ASDF_DIR"/

  echo 'dummy 1.0.0' >"$PROJECT_DIR"/.tool-versions
  mkdir -p "$PROJECT_DIR"/child

  cd "$PROJECT_DIR"/child

  run asdf install

  # execute the generated shim
  assert_equal "$("$ASDF_DIR"/shims/dummy world hello)" "This is Dummy 1.0.0! hello world"
  assert_success
}

@test "install_command installs multiple tool versions when they are specified in a .tool-versions file" {
  echo 'dummy 1.0.0 1.2.0' >"$PROJECT_DIR"/.tool-versions
  cd "$PROJECT_DIR"

  run asdf install
  echo "$output"
  assert_success

  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.0.0/version)" "1.0.0"
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.2.0/version)" "1.2.0"
}

@test "install_command doesn't install system version" {
  run asdf install dummy system
  assert_success
  assert [ ! -f "$ASDF_DIR"/installs/dummy/system/version ]
}

@test "install command executes configured pre plugin install hook" {
  cat >"$HOME"/.asdfrc <<-'EOM'
pre_asdf_install_dummy = echo will install dummy $1
EOM

  run asdf install dummy 1.0.0
  assert_output "will install dummy 1.0.0"
}

@test "install command executes configured post plugin install hook" {
  cat >"$HOME"/.asdfrc <<-'EOM'
post_asdf_install_dummy = echo HEY $version FROM $plugin_name
EOM

  run asdf install dummy 1.0.0
  assert_output "HEY 1.0.0 FROM dummy"
}

@test "install command without arguments installs versions from legacy files" {
  echo 'legacy_version_file = yes' >"$HOME"/.asdfrc
  echo '1.2.0' >>"$PROJECT_DIR"/.dummy-version
  cd "$PROJECT_DIR"
  run asdf install
  assert_success
  assert_output ""
  assert [ -f "$ASDF_DIR"/installs/dummy/1.2.0/version ]
}

@test "install command without arguments installs versions from legacy files in parent directories" {
  echo 'legacy_version_file = yes' >"$HOME"/.asdfrc
  echo '1.2.0' >>"$PROJECT_DIR"/.dummy-version

  mkdir -p "$PROJECT_DIR"/child
  cd "$PROJECT_DIR"/child

  run asdf install
  assert_success
  assert_output ""
  assert [ -f "$ASDF_DIR"/installs/dummy/1.2.0/version ]
}

@test "install_command latest installs latest stable version" {
  run asdf install dummy latest
  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/2.0.0/version)" "2.0.0"
}

@test "install_command latest:version installs latest stable version that matches the given string" {
  run asdf install dummy latest:1
  assert_success
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.1.0/version)" "1.1.0"
}

@test "install_command deletes the download directory" {
  run asdf install dummy 1.1.0
  assert_success
  assert [ ! -d "$ASDF_DIR"/downloads/dummy/1.1.0 ]
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.1.0/version)" "1.1.0"
}

@test "install_command keeps the download directory when --keep-download flag is provided" {
  run asdf install dummy 1.1.0 --keep-download
  assert_success
  assert [ -d "$ASDF_DIR"/downloads/dummy/1.1.0 ]
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.1.0/version)" "1.1.0"
}

@test "install_command keeps the download directory when always_keep_download setting is true" {
  echo 'always_keep_download = yes' >"$HOME"/.asdfrc
  run asdf install dummy 1.1.0
  echo "$output"
  assert_success
  assert [ -d "$ASDF_DIR"/downloads/dummy/1.1.0 ]
  assert_equal "$(cat "$ASDF_DIR"/installs/dummy/1.1.0/version)" "1.1.0"
}
