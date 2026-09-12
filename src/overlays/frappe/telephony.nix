{
  appSources,
  lib,
  buildPythonPackage,
  flit-core,
  pythonRelaxDepsHook,
  python,
  extractFrappeMeta,
}:
buildPythonPackage rec {
  inherit
    (extractFrappeMeta src)
    pname
    version
    format
    ;

  # pure python app, no node assets to build
  inherit (appSources.telephony) src;
  inherit (appSources.telephony) passthru;

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  propagatedBuildInputs = with python.pkgs; [
    bleach
    twilio
  ];

  pythonRelaxDeps = [
    "bleach"
    "twilio"
  ];

  # would require frappe, but since frappe is almost certainly customized,
  # we don't include it here
  # pythonImportsCheck = ["telephony"];

  meta = with lib; {
    description = "Telephony for Frappe apps";
    homepage = "https://github.com/frappe/telephony";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
  };
}
