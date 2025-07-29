{
  lib,
  rustPlatform,
  fetchFromSourcehut,
  symlinkJoin,
  stdenv,
  clang,
  git,
  writeText,
  writeTextDir,
  pkgs,
  ...
}:
let
  inherit (lib) types attrsets strings;
  src = fetchFromSourcehut {
    owner = "~hadronized";
    repo = "kak-tree-sitter";
    rev = "kak-tree-sitter-v2.0.0";
    hash = "sha256-vFhNxixXsezK3Qm9d5hEiIttSjcuqHfgCHYrEOeKWvs=";
  };

  kak-tree-sitter = rustPlatform.buildRustPackage {
    inherit src;
    pname = "kak-tree-sitter";
    version = "2.0.0";
    cargoLock.lockFile = "${src}/Cargo.lock";

    cargoBuildOptions = [
      "--package"
      "kak-tree-sitter"
      "--package"
      "ktsctl"
    ];

    nativeBuildInputs = [
      clang
      git
    ];

    patches = [
      # Allow absolute-path style repos
      (writeText "resources.patch" ''
        diff --git a/ktsctl/src/resources.rs b/ktsctl/src/resources.rs
        index f1da3ff..ac89345 100644
        --- a/ktsctl/src/resources.rs
        +++ b/ktsctl/src/resources.rs
        @@ -48,7 +48,8 @@ impl Resources {
               url
                 .trim_start_matches("http")
                 .trim_start_matches('s')
        -        .trim_start_matches("://"),
        +        .trim_start_matches(":/")
        +        .trim_start_matches("/"),
             );

             self.runtime_dir.join("sources").join(url_dir)
      '')
    ];

    meta.mainProgram = "kak-tree-sitter";
  };

  mkGrammarPackage =
    {
      name,
      src,
      grammarPath ? "src",
      grammarCompileArgs ? [
        "-O3"
        "-c"
        "-fpic"
        "../parser.c"
        "../scanner.c"
        "-I"
        ".."
      ],
      grammarLinkArgs ? [
        "-shared"
        "-fpic"
        "parser.o"
        "scanner.o"
      ],
    }:
    stdenv.mkDerivation {
      inherit src;
      name = "kak-tree-sitter-grammar-${name}.so";
      version = "latest";
      buildPhase = ''
        mkdir ${grammarPath}/build
        cd ${grammarPath}/build
        $CC ${lib.concatStringsSep " " grammarCompileArgs}
        $CC ${lib.concatStringsSep " " grammarLinkArgs} -o ${name}.so
      '';
      installPhase = ''
        cp ${name}.so $out
      '';
    };
  cfg = {
    features = {
      highlighting = true;
      text_objects = true;
    };

    highlighterGroups = {
      attribute = "@attribute";
      comment = "@comment";
      conceal = "%opt{mauve}+i";
      constant = "%opt{peach}";
      constant_builtin_boolean = "%opt{sky}";
      constant_character = "%opt{yellow}";
      constant_macro = "%opt{mauve}";
      constant_numeric = "%opt{peach}";
      constructor = "%opt{sapphire}";
      diff_plus = "%opt{green}";
      diff_minus = "%opt{red}";
      diff_delta = "%opt{blue}";
      diff_delta_moved = "%opt{mauve}";
      error = "%opt{red}+b";
      function = "@function";
      function_builtin = "@builtin";
      function_macro = "+i@ts_function";
      hint = "%opt{blue}+b";
      info = "%opt{green}+b";
      keyword = "keyword";
      keyword_conditional = "+i@ts_keyword";
      keyword_control_conditional = "+i@ts_keyword";
      keyword_control_directive = "+i@ts_keyword";
      keyword_control_import = "+i@ts_keyword";
      keyword_directive = "+i@ts_keyword";
      label = "%opt{sapphire}+i";
      markup_bold = "%opt{peach}+b";
      markup_heading = "%opt{red}";
      markup_heading_1 = "%opt{red}";
      markup_heading_2 = "%opt{mauve}";
      markup_heading_3 = "%opt{green}";
      markup_heading_4 = "%opt{yellow}";
      markup_heading_5 = "%opt{pink}";
      markup_heading_6 = "%opt{teal}";
      markup_heading_marker = "%opt{peach}+b";
      markup_italic = "%opt{pink}+i";
      markup_list_checked = "%opt{green}";
      markup_list_numbered = "%opt{blue}+i";
      markup_list_unchecked = "%opt{teal}";
      markup_list_unnumbered = "%opt{mauve}";
      markup_link_label = "%opt{blue}";
      markup_link_url = "%opt{teal}+u";
      markup_link_uri = "%opt{teal}+u";
      markup_link_text = "%opt{blue}";
      markup_quote = "%opt{crust}";
      markup_raw = "%opt{sky}";
      markup_raw_block = "%opt{sky}";
      markup_raw_inline = "%opt{green}";
      markup_strikethrough = "%opt{crust}+s";
      namespace = "@module";
      operator = "@operator";
      property = "%opt{sky}";
      punctuation = "%opt{overlay2}";
      punctuation_special = "%opt{sky}";
      special = "%opt{blue}";
      spell = "%opt{mauve}";
      string = "%opt{green}";
      string_regex = "%opt{peach}";
      string_regexp = "%opt{peach}";
      string_escape = "%opt{mauve}";
      string_special = "%opt{blue}";
      string_special_path = "%opt{green}";
      string_special_symbol = "%opt{mauve}";
      string_symbol = "%opt{red}";
      tag = "%opt{teal}";
      tag_error = "%opt{red}";
      text_title = "%opt{mauve}";
      type = "@type";
      type_enum_variant = "+i@ts_type";
      variable = "@variable";
      variable_builtin = "@builtin";
      variable_other_member = "%opt{teal}";
      variable_parameter = "+i@variable";
      warning = "%opt{peach}+b";
    };

    extraHighlighterGroups = { };

    aliases = {
      comment_block = "comment";
      comment_line = "comment";
      constant_character_escape = "constant_character";
      constant_numeric_float = "constant_numeric";
      constant_numeric_integer = "constant_numeric";
      function_method = "function";
      function_special = "function";
      keyword_control = "keyword";
      keyword_control_repeat = "keyword";
      keyword_control_return = "keyword";
      keyword_control_except = "keyword";
      keyword_control_exception = "keyword";
      keyword_function = "keyword";
      keyword_operator = "keyword";
      keyword_special = "keyword";
      keyword_storage = "keyword";
      keyword_storage_modifier = "keyword";
      keyword_storage_modifier_mut = "keyword";
      keyword_storage_modifier_ref = "keyword";
      keyword_storage_type = "keyword";
      punctuation_bracket = "punctuation";
      punctuation_delimiter = "punctuation";
      text = "string";
      type_builtin = "type";
    };

    extraAliases = { };

    languages = { };
  };

  allGroups = attrsets.recursiveUpdate cfg.highlighterGroups cfg.extraHighlighterGroups;

  aliases = attrsets.recursiveUpdate cfg.aliases cfg.extraAliases;

  toTs = name: "ts_${strings.concatStringsSep "_" (strings.splitString "." name)}";
  toScm = name: strings.concatStringsSep "." (strings.splitString "_" name);

  definedFaces = attrsets.mapAttrs' (name: value: {
    inherit value;
    name = toTs name;
  }) allGroups;
  aliasFaces = attrsets.mapAttrs' (name: value: {
    name = toTs name;
    value = "@${toTs value}";
  }) aliases;
  faces = attrsets.recursiveUpdate definedFaces aliasFaces;

  toml = pkgs.formats.toml { };

  toLanguageConf =
    name: lang: with lang; {
      grammar = {
        source.local.path = mkGrammarPackage {
          inherit name;
          src = grammar.src;
          grammarPath = grammar.path;
          grammarCompileArgs = grammar.compile.flags ++ grammar.compile.args;
          grammarLinkArgs = grammar.link.flags ++ grammar.link.args;
        };
        compile = grammar.compile.command;
        compile_args = grammar.compile.args;
        compile_flags = grammar.compile.flags;
        link = grammar.link.command;
        link_args = grammar.link.args ++ [
          "-o"
          "${name}.so"
        ];
        link_flags = grammar.link.flags;
      };
      queries = rec {
        path = if queries.path == null then "runtime/queries/${name}" else queries.path;
        source.local.path = "${queries.src}/${path}";
      };
    };

  configFile = toml.generate "config.toml" {
    highlight.groups = builtins.map toScm (builtins.attrNames allGroups ++ builtins.attrNames aliases);
    features = cfg.features;
    language = builtins.mapAttrs toLanguageConf cfg.languages;
  };
in
{
  extraPaths = lib.makeBinPath ([ kak-tree-sitter ]);
  plugin = writeTextDir "share/kak/autoload/kak-tree-sitter.kak" ''
    # Enable kak-tree-sitter
    eval %sh{kak-tree-sitter --config ${configFile} --kakoune -d --server --init $kak_session}
    map global normal <c-t> ": enter-user-mode tree-sitter<ret>"

    # Extra faces
    ${strings.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs (name: face: "face global ${name} \"${face}\"") faces)
    )}
  '';
}
