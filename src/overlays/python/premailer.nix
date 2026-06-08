{
  lib,
  buildPythonPackage,
  fetchPypi,
  cssselect,
  cssutils,
  lxml,
  mock,
  requests,
  cachetools,
}:
buildPythonPackage rec {
  pname = "premailer";
  version = "3.10.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d1875a8411f5dc92b53ef9f193db6c0f879dc378d618e0ad292723e388bfe4c2";
  };

  buildInputs = [
    mock
  ];
  propagatedBuildInputs = [
    cachetools
    cssselect
    cssutils
    lxml
    requests
  ];
  doCheck = false;

  meta = {
    description = "Turns CSS blocks into style attributes";
    homepage = "https://github.com/peterbe/premailer";
    license = lib.licenses.bsd3;
  };
}
