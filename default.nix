let
  onix = import (builtins.fetchGit {
    url = "https://github.com/rizo/onix.git";
    rev = "28d00dd8ea309f2ea9a3b530f35f4f9d989f81d7";
  }) { verbosity = "info"; };

in onix.env {
  path = ./.;

  vars = {
    "with-test" = true;
    "with-doc" = true;
    "with-dev-setup" = true;
  };

  deps = {
    "ocaml-base-compiler" = "<5.4";
    "ocaml-lsp-server" = "*";
    "ocamlformat" = "*";
  };
}
