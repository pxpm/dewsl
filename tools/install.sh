#!/usr/bin/env bash

# This script installs dewsl in the user's home directory.
# Highly inspired by the Spin installer script: https://github.com/serversideup/spin

# Default settings
DEWSL_HOME=${DEWSL_HOME:-$HOME/.dewsl}
DEWSL_CACHE_DIR=${DEWSL_CACHE_DIR:-$DEWSL_HOME/cache}
REPO=${REPO:-pxpm/dewsl}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-'main'}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

get_install_version() {
    if [ ! -z "$BRANCH" ]; then
        echo "$BRANCH"
        return 0
    fi
    # Get latest stable release
    curl --silent \
        -H 'Accept: application/vnd.github.v3.sha' \
        "https://api.github.com/repos/pxpm/dewsl/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"([^"]+)".*/\1/'
}

setup_dewsl() {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
umask g-w,o-w

  command_exists git || {
    echo "[ERROR]: git is not installed"
    exit 1
  }

  DEWSL_INSTALL_VERSION=$(get_install_version)

  echo "[INFO]: Cloning dewsl \"$DEWSL_INSTALL_VERSION\"..."

  # Initialize an empty Git repository
  mkdir -p "$DEWSL_HOME"
  git init "$DEWSL_HOME" --bare 
  cd "$DEWSL_HOME" || exit

  # Add the remote repository
  git remote add -f origin "$REMOTE"

  echo "[INFO]: Checking out dewsl \"$DEWSL_INSTALL_VERSION\"..."

  # Enable sparse checkout and configure it
  #git config core.sparseCheckout true > /dev/null 2>&1
  #echo "/*" > .git/info/sparse-checkout
  #echo "!/docs" >> .git/info/sparse-checkout
  #echo "!/.github" >> .git/info/sparse-checkout
  #echo "!/composer.json" >> .git/info/sparse-checkout
  #echo "!/package.json" >> .git/info/sparse-checkout
  #echo "!/.npmignore" >> .git/info/sparse-checkout

  # Fetch and checkout the specific branch with depth 1
  #git fetch --depth=1 origin "$SPIN_INSTALL_VERSION" > /dev/null 2>&1
  #git checkout FETCH_HEAD > /dev/null 2>&1

  # Additional setup steps
  #set_configuration_file
  #save_last_update_check_time
  #prompt_to_add_path

  #echo #Empty line
}


setup_dewsl "$@"