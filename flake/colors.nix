{ runCommand, ... }:
runCommand "mtn-kak-colors"
  {
    src = ./colors;
  }
  ''
    mkdir -p $out/share/kak/colors/
    cp -v ${./colors}/* $out/share/kak/colors/
  ''
