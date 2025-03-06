let
  inputs = import ../npins;
  pkgs = import inputs.nixpkgs { };
  pythonEnv = pkgs.python311.withPackages (ps: [
    ps.transformers
    ps.torch
    ps.pandas
    ps.gensim
    ps.numpy
    ps.sentence-transformers
    ps.jupyter
    ps.notebook
  ]);
in
pkgs.mkShell rec {
  packages = [
    pythonEnv
  ];

  catchConflicts = false;
  shellHook = ''
    export CUSTOM_INTERPRETER_PATH="${pythonEnv}/bin/python"
  '';
}
