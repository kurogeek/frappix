{
  appSources,
  lib,
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  python,
  extractFrappeMeta,
  mkAssets,
  frappe,
}:
buildPythonPackage rec {
  inherit
    (extractFrappeMeta src)
    pname
    version
    format
    ;

  src = mkAssets {
    inherit (appSources.erpnext) pname version src;
    yarnHash = "sha256-25VPD0K192AMYRmOHhMao6I3As/KW9LvulB/6zK2Wbk=";
  };

  inherit (appSources.erpnext) passthru;

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  propagatedBuildInputs = with python.pkgs; [
    barcodenumber
    googlemaps
    holidays
    plaid-python
    pycountry
    pypng
    # temporary fix until https://github.com/NixOS/nixpkgs/pull/556318 is merged
    (python-youtube.overrideAttrs { disabledTests = [ "test_parse_response" ]; })
    rapidfuzz
    tweepy
    unidecode
  ];

  pythonRelaxDeps = [
    # - pycountry~=22.3.5 not satisfied by version 23.12.11
    "pycountry"
    # - rapidfuzz~=2.15.0 not satisfied by version 3.9.1
    "rapidfuzz"
    # - python-youtube~=0.8.0 not satisfied by version 0.9.4
    "python-youtube"
    "unidecode"
    "pypng"
  ];

  nativeCheckInputs = [frappe];

  pythonImportsCheck = ["erpnext"];

  meta = with lib; {
    description = "Free and Open Source Enterprise Resource Planning (ERP";
    homepage = "https://github.com/frappe/erpnext";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [blaggacao];
  };
}
