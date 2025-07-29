{ ... }@inputs:
let
  overlay-versioning = final: prev: {
    kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (attrs: {
      version = "r${builtins.substring 0 6 inputs.kakoune.rev}";
      src = inputs.kakoune;
      patches = [
        # patches in the original package was already applied
      ];
    });
    kak-lsp = final.unstable.rustPlatform.buildRustPackage {
      name = "kak-lsp";
      src = inputs.kak-lsp;
      cargoLock.lockFile = "${inputs.kak-lsp}/Cargo.lock";
      buildInputs = [ final.libiconv ];

      meta.mainProgram = "kak-lsp";
    };
  };

  overlay-package = final: prev: {
    mtn-kakoune = final.callPackage ./default.nix { };
  };
in
[
  overlay-versioning
  overlay-package
]
