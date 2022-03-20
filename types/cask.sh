action=$1
name=$2
shift 2
appdir=$(arguments get appdir $*)

case $action in
  desc)
    echo "asserts presence of apps installed via Homebrew Casks on macOS"
    echo "* cask app-name         (installs cask)"
    echo "--appdir=/Applications  (changes symlink path)"
    ;;

  status)
    baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
    needs_exec "brew" || return $STATUS_FAILED_PRECONDITION
    bake brew --version > /dev/null
    [ "$?" -gt 0 ] && return $STATUS_FAILED_PRECONDITION

    list=$(bake brew list --cask)
    echo "$list" | grep -E "^$name$" > /dev/null
    [ "$?" -gt 0 ] && return $STATUS_MISSING

    info=$(bake brew info --cask $name)
    echo "$info" | grep 'Not installed' > /dev/null
    [ "$?" -eq 0 ] && return $STATUS_OUTDATED

    return 0 ;;

  install)
    if [ -n "$appdir"  ]; then
      HOMEBREW_NO_AUTO_UPDATE=true bake brew install --cask $name --appdir=$appdir
    else
      HOMEBREW_NO_AUTO_UPDATE=true bake brew install --cask $name
    fi
    ;;

  upgrade)
    if [ -n "$appdir" ]; then
      HOMEBREW_NO_AUTO_UPDATE=true bake brew upgrade --cask $name --appdir=$appdir
    else
      HOMEBREW_NO_AUTO_UPDATE=true bake brew upgrade --cask $name
    fi
    ;;

  inspect)
    baking_platform_is "Darwin" || return $STATUS_UNSUPPORTED_PLATFORM
    needs_exec "brew" || return $STATUS_FAILED_PRECONDITION
    installed=$(bake brew list --cask)
    while IFS= read -r cask; do
        echo "ok cask $cask"
    done <<< "$installed"
    ;;

  remove)
    HOMEBREW_NO_AUTO_UPDATE=true bake brew remove --cask $name
    ;;

  *) return 1 ;;
esac
