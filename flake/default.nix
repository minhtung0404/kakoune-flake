{
  callPackage,
  kakoune,
  kakoune-unwrapped,
  mtn-kak-util ? callPackage ./utils.nix { },
  mtn-kak-lsp ? callPackage ./lsp.nix { },
  mtn-kak-tree-sitter ? callPackage ./tree-sitter.nix { },
  mtn-kak-rc ? callPackage ./rc.nix { },
  mtn-kak-plugins ? callPackage ./plugins.nix { utils = mtn-kak-util; },
  # kak-kaktex ? callPackage ./kaktex { },
  mtn-kak-colors ? callPackage ./colors.nix { },
  mtn-kak-autoload ? callPackage ./autoload.nix { },
  mtn-kak-faces ? callPackage ./faces.nix { utils = mtn-kak-util; },
  ...
}:
(kakoune.override {
  kakoune = kakoune-unwrapped;
  plugins = [
    mtn-kak-rc
    mtn-kak-lsp.plugin
    mtn-kak-tree-sitter.plugin
    mtn-kak-colors
    mtn-kak-autoload
    mtn-kak-faces
  ]
  ++ mtn-kak-plugins;
  # ++ [
  #   kak-kaktex
  # ];
}).overrideAttrs
  (attrs: {
    buildCommand = ''
      ${attrs.buildCommand or ""}
      # location of kak binary is used to find ../share/kak/autoload,
      # unless explicitly overriden with KAKOUNE_RUNTIME
      rm "$out/bin/kak"
      makeWrapper "${kakoune-unwrapped}/bin/kak" "$out/bin/kak" \
        --set KAKOUNE_RUNTIME "$out/share/kak" \
        --suffix PATH ":" "${mtn-kak-lsp.extraPaths}:${mtn-kak-tree-sitter.extraPaths}"
    '';

    passthru = {
      lsp = mtn-kak-lsp;
      rc = mtn-kak-rc;
      plugins = mtn-kak-plugins;
      # kaktex = kak-kaktex;
      colors = mtn-kak-colors;
      autoload = mtn-kak-autoload;
      faces = mtn-kak-faces;
      util = mtn-kak-util;
    };
  })
