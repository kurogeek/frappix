{
  appSources,
  lib,
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  python,
  extractFrappeMeta,
  applyPatches,
  stdenv,
  fetchYarnDeps,
  nodejs,
  yarnConfigHook,
}:
let
  src = applyPatches{
    inherit (appSources.crm) src;
    name = "patched-crm";
    patches = [
      ./crm-0001-build-socket-port-is-reverse-proxied.patch
    ];
  };
  version = appSources.hrms.version;


  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "crm-frontend";
    inherit version;

    src = "${src}/frontend";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-OdETUUCFI1jxGqT4XQiSXVR4FhViSUX1WJjJnSZOcj8=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      substituteInPlace $TMP/frontend/vite.config.js --replace-fail "../crm/www" out/public/www

      substituteInPlace $TMP/frontend/package.json --replace-fail "../crm/public/frontend" dist
      substituteInPlace $TMP/frontend/package.json --replace-fail "../crm/www" out/public/www

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p out/public/frontend
      mkdir -p out/public/www
      mkdir $out

      npm run build

      cp -R dist/* out/public/frontend

      cp -R out/* $out

      runHook postInstall
    '';
  });

  crm = stdenv.mkDerivation (finalAttrs: {
    pname = "crm";
    inherit version;

    inherit src;

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-oZgyP0hTU9bxszOVg3Bmiu6yos2d2Inc1Do8To4z8GQ=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/crm/www

      cp -R crm/public $out/crm
      cp -R crm/www $out/crm
      cp -R node_modules $out/crm/public

      cp -R ${frontend}/public/frontend $out/crm/public

      cp -R ${frontend}/public/www/* $out/crm/www

      runHook postInstall
    '';
  });

in
buildPythonPackage {
  inherit
    (extractFrappeMeta src)
    pname
    version
    format
    ;

  src = stdenv.mkDerivation {
    pname = "crm_";
    inherit src version;
    installPhase = ''
      mkdir $out
      cp -R . $out
      cp -R ${crm}/crm/public/node_modules $out

      cp -R ${crm}/crm/public/frontend $out/crm/public
      cp -R ${crm}/crm/www/crm.html $out/crm/www/
    '';
  };
  inherit (appSources.crm) passthru;

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  propagatedBuildInputs = with python.pkgs; [
    twilio
  ];

  pythonRelaxDeps = [
    "twilio"
  ];

  # pythonImportsCheck = ["crm"];

  meta = with lib; {
    description = "Delightful, open-source, work communication tool for remote teams";
    homepage = "https://github.com/frappe/crm";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [blaggacao];
  };
}
