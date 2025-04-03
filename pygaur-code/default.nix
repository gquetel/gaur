# Use structure from: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md#python-python
{
  buildPythonPackage,

  # Build system dependencies
  setuptools,

  # Runtime dependencies
  pandas,
  gensim,
  numpy,
  sentence-transformers,
  transformers,
  torch,
}:

buildPythonPackage rec {
  pname = "pygaur";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  buildInputs = [setuptools];
  dependencies = [
    pandas
    gensim
    numpy
    sentence-transformers
    transformers
    torch
  ];

  pythonImportsCheck = [ "pygaur" ];  

  doCheck = false;
}
