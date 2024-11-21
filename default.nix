let
  onix = import (builtins.fetchGit {
    url = "https://github.com/rizo/onix.git";
    rev = "51a241a59f1a2a8d5f2e44eef48f53eaf86d155c";
  }) { verbosity = "info"; };

in onix.env {
  path = ./.;
  env-file = ./.onix.env;

  vars = {
    "with-test" = true;
    "with-doc" = true;
    "with-dev-setup" = true;
  };

  deps = {
    "ocaml-system" = "5.2.0";
    "ocaml-lsp-server" = "*";
    "ocamlformat" = "*";
  };
}
