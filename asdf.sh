# lintball lang=bash

# For Korn shells (ksh, mksh, etc.), capture $_ (the final parameter passed to
# the last command) straightaway, as it will contain the path to this script.
# For Bash, ${BASH_SOURCE[0]} will be used to obtain this script's path.
# For Zsh and others, $0 (the path to the shell or script) will be used.
_under="$_"
if [ "${BASH_SOURCE[0]}" != "" ]; then
  current_script_path="${BASH_SOURCE[0]}"
elif [[ $_under == *".sh" ]]; then
  current_script_path="$_under"
else
  current_script_path="$0"
fi

if echo "$PATH" | grep -qF ";"; then
  # Windows
  export PATH_COLON=";"
else
  # Unix
  export PATH_COLON=":"
fi

export ASDF_DIR
ASDF_DIR="$(dirname "$current_script_path")"
# shellcheck disable=SC2016
[ -d "$ASDF_DIR" ] || echo '$ASDF_DIR is not a directory'

# Add asdf to PATH
#
# if in $PATH, remove, regardless of if it is in the right place (at the front) or not.
# replace all occurrences - ${parameter//pattern/string}
ASDF_BIN="${ASDF_DIR}/bin"
ASDF_USER_SHIMS="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
[[ "${PATH_COLON}${PATH}${PATH_COLON}" == *"${PATH_COLON}${ASDF_BIN}${PATH_COLON}"* ]] && PATH="${PATH//${ASDF_BIN}${PATH_COLON}/}"
[[ "${PATH_COLON}${PATH}${PATH_COLON}" == *"${PATH_COLON}${ASDF_USER_SHIMS}${PATH_COLON}"* ]] && PATH="${PATH//${ASDF_USER_SHIMS}${PATH_COLON}/}"
# add to front of $PATH
PATH="${ASDF_BIN}${PATH_COLON}${PATH}"
PATH="${ASDF_USER_SHIMS}${PATH_COLON}${PATH}"

# shellcheck source=lib/asdf.sh
# Load the asdf wrapper function
. "${ASDF_DIR}/lib/asdf.sh"
