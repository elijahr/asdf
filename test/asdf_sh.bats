#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load test_helpers

# Helper function to handle sourcing of asdf.sh
source_asdf_sh() {
  . $(dirname "$BATS_TEST_DIRNAME")/asdf.sh
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    echo $ASDF_DIR
  )

  output=$(echo "$result" | grep "asdf")
  assert_equal "$?" 0
  assert [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    echo $PATH
  )

  output=$(echo "$result" | grep "asdf")
  assert_equal "$?" 0
  assert [ "$output" != "" ]
}

@test "does not add paths to PATH more than once" {
  result=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    source_asdf_sh
    echo $PATH
  )

  output=$(echo $PATH | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  assert_equal "$?" 0
  assert_output ""
}

@test "defines the asdf function" {
  output=$(
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    source_asdf_sh
    type asdf
  )

  [[ $output =~ "is a function" ]]
}
