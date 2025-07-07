let
  onix = import (builtins.fetchGit {
    url = "https://github.com/rizo/onix.git";
    rev = "28d00dd8ea309f2ea9a3b530f35f4f9d989f81d7";
  }) { verbosity = "info"; };

in onix.env {
  path = ./.;

  vars = {
    "with-test" = false;
    "with-doc" = false;
    "with-dev-setup" = false;
  };

  deps = {
    "ocaml-base-compiler" = "5.3.0";
    "ocaml-lsp-server" = "*";
    "ocamlformat" = "*";
  };
}
