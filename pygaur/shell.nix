let
  inputs = import ./npins; 
  pkgs =  import inputs.nixpkgs { };
  package = import ./default.nix;
in
pkgs.mkShell {
  buildInputs = [
    package
    pkgs.python3
  ];
}