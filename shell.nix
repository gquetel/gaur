let 
    inputs = import ./npins; 
    pkgs =  import inputs.nixpkgs { };
    pygaur-package = import ./pygaur/default.nix;
in 

pkgs.mkShell {
  buildInputs = [
    pygaur-package 
    pkgs.flex
    pkgs.bison
    pkgs.libgcc
    pkgs.gnumake
  ];
}