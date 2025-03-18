let
  inputs = import ./npins;
  pkgs = import inputs.nixpkgs { };
  pygaur = pkgs.callPackage ./pygaur/default.nix {
    inherit (pkgs.python311Packages) 
    buildPythonPackage
    setuptools
    pandas
    gensim
    numpy
    sentence-transformers
    transformers
    torch
    ;
  };
  pythonEnv = pkgs.python311.withPackages (ps: [
    pygaur
    # Pkgs to use notebooks
    ps.ipykernel
    ps.notebook
    # python pkgs used outside the pygaur framework for experiments, if packages finally get used by pygaur, move them to ./pygaur/default.nix

    ps.transformers
    ps.torch
    ps.pandas
    ps.gensim
    ps.numpy
    ps.sentence-transformers
  ]);
in
pkgs.mkShell rec {
  packages = [
    pythonEnv
    pkgs.flex
    pkgs.bison
    pkgs.libgcc
    pkgs.gnumake
  ];

  catchConflicts = false;
  shellHook = ''
    export CUSTOM_INTERPRETER_PATH="${pythonEnv}/bin/python"
  '';
}
