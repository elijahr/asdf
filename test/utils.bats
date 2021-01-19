#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  install_dummy_version "0.1.0"
  install_dummy_version "0.2.0"

  PROJECT_DIR=$HOME/project
  mkdir -p "$PROJECT_DIR"

  cd "$HOME"
}

teardown() {
  clean_asdf_dir
}

@test "get_install_path should output version path when version is provided" {
  run get_install_path foo version "1.0.0"
  assert_success
  install_path=${output#$HOME/}
  assert_equal "$install_path" ".asdf/installs/foo/1.0.0"
}

@test "get_install_path should output custom path when custom install type is provided" {
  run get_install_path foo custom "1.0.0"
  assert_success
  install_path=${output#$HOME/}
  assert_equal "$install_path" ".asdf/installs/foo/custom-1.0.0"
}

@test "get_install_path should output path when path version is provided" {
  run get_install_path foo path "/some/path"
  assert_success
  assert_output "/some/path"
}

@test "get_download_path should output version path when version is provided" {
  run get_download_path foo version "1.0.0"
  assert_success
  download_path=${output#$HOME/}
  echo "$download_path"
  assert_equal "$download_path" ".asdf/downloads/foo/1.0.0"
}

@test "get_download_path should output custom path when custom download type is provided" {
  run get_download_path foo custom "1.0.0"
  assert_success
  download_path=${output#$HOME/}
  assert_equal "$download_path" ".asdf/downloads/foo/custom-1.0.0"
}

@test "get_download_path should output nothing when path version is provided" {
  run get_download_path foo path "/some/path"
  assert_success
  assert_output ""
}

@test "check_if_version_exists should exit with 1 if plugin does not exist" {
  run check_if_version_exists "inexistent" "1.0.0"
  assert_failure
  assert_output "No such plugin: inexistent"
}

@test "check_if_version_exists should exit with 1 if version does not exist" {
  run check_if_version_exists "dummy" "1.0.0"
  assert_failure
}

@test "version_not_installed_text is correct" {
  run version_not_installed_text "dummy" "1.0.0"
  assert_success
  assert_output "version 1.0.0 is not installed for dummy"
}

@test "check_if_version_exists should be noop if version exists" {
  run check_if_version_exists "dummy" "0.1.0"
  assert_success
  assert_output ""
}

@test "check_if_version_exists should be noop if version is system" {
  mkdir -p "$ASDF_DIR"/plugins/foo
  run check_if_version_exists "foo" "system"
  assert_success
  assert_output ""
}

@test "check_if_version_exists should be ok for ref:version install" {
  mkdir -p "$ASDF_DIR"/plugins/foo
  mkdir -p "$ASDF_DIR"/installs/foo/ref-master
  run check_if_version_exists "foo" "ref:master"
  assert_success
  assert_output ""
}

@test "check_if_plugin_exists should exit with 1 when plugin is empty string" {
  run check_if_plugin_exists
  assert_failure
  assert_output "No plugin given"
}

@test "check_if_plugin_exists should be noop if plugin exists" {
  run check_if_plugin_exists "dummy"
  assert_success
  assert_output ""
}

@test "parse_asdf_version_file should output version" {
  echo "dummy 0.1.0" >"$PROJECT_DIR"/.tool-versions
  run parse_asdf_version_file "$PROJECT_DIR"/.tool-versions dummy
  assert_success
  assert_output "0.1.0"
}

@test "parse_asdf_version_file should output path on project with spaces" {
  outer="$PROJECT_DIR/outer space"
  mkdir -p "$outer"
  cd "$outer"
  echo "dummy 0.1.0" >"$outer/.tool-versions"
  run parse_asdf_version_file "$outer/.tool-versions" dummy
  assert_success
  assert_output "0.1.0"
}

@test "parse_asdf_version_file should output path version with spaces" {
  echo "dummy path:/some/dummy path" >"$PROJECT_DIR"/.tool-versions
  run parse_asdf_version_file "$PROJECT_DIR"/.tool-versions dummy
  assert_success
  assert_output "path:/some/dummy path"
}

@test "find_versions should return .tool-versions if legacy is disabled" {
  echo "dummy 0.1.0" >"$PROJECT_DIR"/.tool-versions
  echo "0.2.0" >"$PROJECT_DIR"/.dummy-version

  run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  assert_output "0.1.0|$PROJECT_DIR/.tool-versions"
}

@test "find_versions should return the legacy file if supported" {
  echo "legacy_version_file = yes" >"$HOME"/.asdfrc
  echo "dummy 0.1.0" >"$HOME"/.tool-versions
  echo "0.2.0" >"$PROJECT_DIR"/.dummy-version

  run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  assert_output "0.2.0|$PROJECT_DIR/.dummy-version"
}

@test "find_versions skips .tool-version file that don't list the plugin" {
  echo "dummy 0.1.0" >"$HOME"/.tool-versions
  echo "another_plugin 0.3.0" >"$PROJECT_DIR"/.tool-versions

  run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  assert_output "0.1.0|$HOME/.tool-versions"
}

@test "find_versions should return .tool-versions if unsupported" {
  echo "dummy 0.1.0" >"$HOME"/.tool-versions
  echo "0.2.0" >"$PROJECT_DIR"/.dummy-version
  echo "legacy_version_file = yes" >"$HOME"/.asdfrc
  rm "$ASDF_DIR"/plugins/dummy/bin/list-legacy-filenames

  run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  assert_output "0.1.0|$HOME/.tool-versions"
}

@test "find_versions should return the version set by envrionment variable" {
  ASDF_DUMMY_VERSION=0.2.0 run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  echo "$output"
  assert_output "0.2.0|ASDF_DUMMY_VERSION environment variable"
}

@test "asdf_data_dir should return user dir if configured" {
  ASDF_DATA_DIR="/tmp/wadus"

  run asdf_data_dir
  assert_success
  assert_output "$ASDF_DATA_DIR"
}

@test "asdf_data_dir should return ~/.asdf when ASDF_DATA_DIR is not set" {
  unset ASDF_DATA_DIR

  run asdf_data_dir
  assert_success
  assert_output "$HOME/.asdf"
}

@test "check_if_plugin_exists should work with a custom data directory" {
  ASDF_DATA_DIR=$HOME/asdf-data

  mkdir -p "$ASDF_DATA_DIR/plugins"
  mkdir -p "$ASDF_DATA_DIR/installs"

  install_mock_plugin "dummy2" "$ASDF_DATA_DIR"
  install_mock_plugin_version "dummy2" "0.1.0" "$ASDF_DATA_DIR"

  run check_if_plugin_exists "dummy2"
  assert_success
  assert_output ""
}

@test 'find_versions should return ASDF_DEFAULT_TOOL_VERSIONS_FILENAME if set' {
  ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$PROJECT_DIR/global-tool-versions"
  echo "dummy 0.1.0" >"$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"

  run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  assert_output "0.1.0|$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
}

@test 'find_versions should check HOME legacy files before ASDF_DEFAULT_TOOL_VERSIONS_FILENAME' {
  ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$PROJECT_DIR/global-tool-versions"
  echo "dummy 0.2.0" >"$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
  echo "dummy 0.1.0" >"$HOME"/.dummy-version
  echo "legacy_version_file = yes" >"$HOME"/.asdfrc

  run find_versions "dummy" "$PROJECT_DIR"
  assert_success
  [[ $output =~ 0.1.0|$HOME/.dummy-version ]]
}

@test "get_preset_version_for returns the current version" {
  cd "$PROJECT_DIR"
  echo "dummy 0.2.0" >.tool-versions
  run get_preset_version_for "dummy"
  assert_success
  assert_output "0.2.0"
}

@test "get_preset_version_for returns the global version from home when project is outside of home" {
  echo "dummy 0.1.0" >"$HOME"/.tool-versions
  dir="$BASE_DIR"/project
  mkdir -p "$dir"
  PROJECT_DIR="$dir" run get_preset_version_for "dummy"
  assert_success
  assert_output "0.1.0"
}

@test "get_preset_version_for returns the tool version from env if ASDF_{TOOL}_VERSION is defined" {
  cd "$PROJECT_DIR"
  echo "dummy 0.2.0" >.tool-versions
  ASDF_DUMMY_VERSION=3.0.0 run get_preset_version_for "dummy"
  assert_success
  assert_output "3.0.0"
}

@test "get_preset_version_for should return branch reference version" {
  cd "$PROJECT_DIR"
  echo "dummy ref:master" >"$PROJECT_DIR"/.tool-versions
  run get_preset_version_for "dummy"
  assert_success
  assert_output "ref:master"
}

@test "get_preset_version_for should return path version" {
  cd "$PROJECT_DIR"
  echo "dummy path:/some/place with spaces" >"$PROJECT_DIR"/.tool-versions
  run get_preset_version_for "dummy"
  assert_success
  assert_output "path:/some/place with spaces"
}

@test "get_executable_path for system version should return system path" {
  mkdir -p "$ASDF_DIR"/plugins/foo
  run get_executable_path "foo" "system" "ls"
  assert_success
  assert_output "$(which ls)"
}

@test "get_executable_path for system version should not use asdf shims" {
  mkdir -p "$ASDF_DIR"/plugins/foo
  touch "$ASDF_DIR"/shims/dummy_executable
  chmod +x "$ASDF_DIR"/shims/dummy_executable

  run which dummy_executable
  assert_success

  run get_executable_path "foo" "system" "dummy_executable"
  assert_failure
}

@test "get_executable_path for non system version should return relative path from plugin" {
  mkdir -p "$ASDF_DIR"/plugins/foo
  mkdir -p "$ASDF_DIR"/installs/foo/1.0.0/bin
  executable_path=$ASDF_DIR/installs/foo/1.0.0/bin/dummy
  touch "$executable_path"
  chmod +x "$executable_path"

  run get_executable_path "foo" "1.0.0" "bin/dummy"
  assert_success
  assert_output "$executable_path"
}

@test "get_executable_path for ref:version installed version should resolve to ref-version" {
  mkdir -p "$ASDF_DIR"/plugins/foo
  mkdir -p "$ASDF_DIR"/installs/foo/ref-master/bin
  executable_path=$ASDF_DIR/installs/foo/ref-master/bin/dummy
  touch "$executable_path"
  chmod +x "$executable_path"

  run get_executable_path "foo" "ref:master" "bin/dummy"
  assert_success
  assert_output "$executable_path"
}

@test "find_tool_versions will find a .tool-versions path if it exists in current directory" {
  echo "dummy 0.1.0" >"$PROJECT_DIR"/.tool-versions
  cd "$PROJECT_DIR"

  run find_tool_versions
  assert_success
  assert_output "$PROJECT_DIR/.tool-versions"
}

@test "find_tool_versions will find a .tool-versions path if it exists in parent directory" {
  echo "dummy 0.1.0" >"$PROJECT_DIR"/.tool-versions
  mkdir -p "$PROJECT_DIR"/child
  cd "$PROJECT_DIR"/child

  run find_tool_versions
  assert_success
  assert_output "$PROJECT_DIR/.tool-versions"
}

@test "get_version_from_env returns the version set in the environment variable" {
  export ASDF_DUMMY_VERSION=0.1.0
  run get_version_from_env 'dummy'

  assert_success
  assert_output '0.1.0'
}

@test "get_version_from_env returns nothing when environment variable is not set" {
  run get_version_from_env 'dummy'

  assert_success
  assert_output ''
}

@test "resolve_symlink converts the symlink path to the real file path" {
  touch foo
  ln -s "$(pwd)"/foo bar

  run resolve_symlink bar
  assert_success
  assert_output "$(pwd)/foo"
  rm -f foo bar
}

@test "resolve_symlink converts relative symlink directory path to the real file path" {
  mkdir baz
  ln -s ../foo baz/bar

  run resolve_symlink baz/bar
  assert_success
  assert_output "$(pwd)/baz/../foo"
  rm -f foo bar
}

@test "resolve_symlink converts relative symlink path to the real file path" {
  touch foo
  ln -s foo bar

  run resolve_symlink bar
  assert_success
  assert_output "$(pwd)/foo"
  rm -f foo bar
}

@test "strip_tool_version_comments removes lines that only contain comments" {
  cat <<EOF >test_file
# comment line
ruby 2.0.0
EOF
  run strip_tool_version_comments test_file
  assert_success
  assert_output "ruby 2.0.0"
}
@test "strip_tool_version_comments removes lines that only contain comments even with missing newline" {
  echo -n "# comment line" >test_file
  run strip_tool_version_comments test_file
  assert_success
  assert_output ""
}

@test "strip_tool_version_comments removes trailing comments on lines containing version information" {
  cat <<EOF >test_file
ruby 2.0.0 # inline comment
EOF
  run strip_tool_version_comments test_file
  assert_success
  assert_output "ruby 2.0.0"
}

@test "strip_tool_version_comments removes trailing comments on lines containing version information even with missing newline" {
  echo -n "ruby 2.0.0 # inline comment" >test_file
  run strip_tool_version_comments test_file
  assert_success
  assert_output "ruby 2.0.0"
}

@test "strip_tool_version_comments removes all comments from the version file" {
  cat <<EOF >test_file
ruby 2.0.0 # inline comment
# comment line
erlang 18.2.1 # inline comment
EOF
  expected="$(
    cat <<EOF
ruby 2.0.0
erlang 18.2.1
EOF
  )"
  run strip_tool_version_comments test_file
  assert_success
  assert_output "$expected"
}

@test "with_shim_executable doesn't crash when executable names contain dashes" {
  cd "$PROJECT_DIR"
  echo "dummy 0.1.0" >"$PROJECT_DIR"/.tool-versions
  mkdir -p "$ASDF_DIR"/installs/dummy/0.1.0/bin
  touch "$ASDF_DIR"/installs/dummy/0.1.0/bin/test-dash
  chmod +x "$ASDF_DIR"/installs/dummy/0.1.0/bin/test-dash
  run asdf reshim dummy 0.1.0

  message="callback invoked"

  function callback() {
    echo "$message"
  }

  run with_shim_executable test-dash callback
  assert_success
  assert_output "$message"
}
