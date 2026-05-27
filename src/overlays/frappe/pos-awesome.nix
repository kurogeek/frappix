{
  lib,
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  stdenv,
  yarnConfigHook,
  fetchYarnDeps,
  nodejs,
  python,
  fetchFromGitHub,
}:
let
  version = "15.30.0";

  src = fetchFromGitHub {
    owner = "defendicon";
    repo = "POS-Awesome-V15";
    tag = version;
    hash = "sha256-oADxAloAQxGdJrANuSgy9nchA4Zuvyy3G0isGUzqeck=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "posawesome-frontend";
    inherit version;

    src = "${src}/frontend";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-EPR9Wy7rd4ytnN762p8now1z0dF+4QmODosz/UkHjr4=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    patchPhase = ''
      cp ${src}/frappe-vue-style.js $TMP/frontend
      cp ${src}/posawesome/public/css/rtl.css $TMP/frontend
    '';

    buildPhase = ''
      runHook preBuild

      substituteInPlace $TMP/frontend/vite.config.js --replace-fail "../posawesome/public" out/public
      substituteInPlace $TMP/frontend/vite.config.js --replace-fail "../frappe-vue-style" "./frappe-vue-style"
      substituteInPlace $TMP/frontend/src/posapp/posapp.ts --replace-fail "../../../posawesome/public/css/rtl.css" "../../rtl.css"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p out/public/frontend
      mkdir -p out/public/www
      mkdir $out

      npm run build

      cp -R out/* $out

      runHook postInstall
    '';
  });

  posawesome = stdenv.mkDerivation (finalAttrs: {
    pname = "posawesome-assets";
    inherit version;

    inherit src;


    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-AJowaeraNyzbtf9mM/eD4qnAs1+GorUZo66xVPNToYI=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/posawesome/www

      cp -R posawesome/public $out/posawesome
      cp -R node_modules $out/posawesome/public

      cp -R ${frontend}/public/frontend $out/posawesome/public

      runHook postInstall
    '';
  });

in
buildPythonPackage  {

  pname = "posawesome";
  version = version;
  format = "pyproject";

  src = stdenv.mkDerivation {
    pname = "posawesome-src";
    inherit src version;
    installPhase = ''
      mkdir -p $out/posawesome/www

      cp -R . $out
      cp -R ${posawesome}/posawesome/public/node_modules $out

      cp -R ${posawesome}/posawesome/public/frontend $out/posawesome/public
    '';
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  postFixup = ''
    runHook preInstall

    cp -R ${posawesome}/posawesome/public/* $out/${python.sitePackages}/posawesome/public

    runHook postInstall
  '';

  meta = with lib; {
    license = licenses.agpl3Only;
    maintainers = with maintainers; [kurogeek];
  };
}
