let
  inputs = import ./npins; 
  pkgs =  import inputs.nixpkgs { };
in
pkgs.python311Packages.buildPythonPackage {
  pname = "pygaur";
  version = "0.1.0";
  src = ./.;
  
  propagatedBuildInputs = with pkgs.python311Packages; [
    pandas
    gensim
    numpy
    matplotlib
    sentence-transformers
    networkx
    scipy
  ];

  doCheck = false;
}
