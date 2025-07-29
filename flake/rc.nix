{
  lib,
  bash,
  writeScript,
  writeTextDir,
  prependRc ? "",
  appendRc ? "",
  ...
}:

let
  source-pwd = writeScript "source-pwd" ''
    #!/usr/bin/env ${lib.getExe bash}

    # Exit if we're already in ~/.config/kak
    if [ "$(pwd)" = "$HOME/.config/kak" ]; then
      exit 0
    fi

    while true; do
      kakrc="$(pwd)/.kakrc"

      if [ -f "$kakrc" ]; then
        echo "source $kakrc"
      fi

      if [ "$(pwd)" = "/" ]; then
        exit 0
      fi

      cd ..
    done
  '';
in
writeTextDir "share/kak/kakrc.local" ''
  ${prependRc}
  ${builtins.readFile ./kakrc}
  ${appendRc}

  # Source any settings in the current working directory,
  # recursive upwards
  evaluate-commands %sh{
    ${source-pwd}
  }
''
