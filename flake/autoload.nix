{ runCommand, ... }:
runCommand "mtn-kak-autoload"
  {
    src = ./autoload;
  }
  ''
    mkdir -p $out/share/kak/autoload/
    cp -v ${./colors}/* $out/share/kak/autoload/
  ''
