{
  appSources,
  lib,
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  extractFrappeMeta,
  stdenv,
  yarnConfigHook,
  fetchYarnDeps,
  nodejs,
  applyPatches,
  python,
}:
let
  src = applyPatches {
    name = "patched-hrms";
    inherit (appSources.hrms) src;
    patches = [
      ./hrms-0001-build-socket-port-is-reverse-proxied.patch
    ];
  };
  version = appSources.hrms.version;

  roster = stdenv.mkDerivation (finalAttrs: {
    pname = "hrms-roster";
    inherit version;

    src = "${src}/roster";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-VIzVC1iPzxTXbfPodHBzs+uCdgXvypn05+9prnW3d2Q=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      export PATH=$PATH:$TMP/roster/node_modules/.bin
      substituteInPlace $TMP/roster/vite.config.js --replace-fail "../hrms/public/roster" out/public/roster
      substituteInPlace $TMP/roster/package.json --replace-fail "../hrms/public/roster" out/public/roster
      substituteInPlace $TMP/roster/package.json --replace-fail "../hrms/www" out/public/www

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p out/public/roster
      mkdir -p out/public/www
      mkdir $out

      npm run build

      cp -R out/* $out

      runHook postInstall
    '';

  });


  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "hrms-frontend";
    inherit version;

    src = "${src}/frontend";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-LsrTcd3roLFcCHbGjkIed+1gu9JnGQWN+gA3yZPV6F0=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      export PATH=$PATH:$TMP/frontend/node_modules/.bin
      substituteInPlace $TMP/frontend/vite.config.js --replace-fail "../hrms/public/frontend" out/public/frontend
      substituteInPlace $TMP/frontend/package.json --replace-fail "../hrms/public/frontend" out/public/frontend
      substituteInPlace $TMP/frontend/package.json --replace-fail "../hrms/www" out/public/www

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

  hrms = stdenv.mkDerivation (finalAttrs: {
    pname = "hrms";
    inherit version;

    inherit src;


    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-HdOG5Lp2+E9bFEj+wpLM9o6dIAy05IVffWx2QeAf/K4=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/hrms/www
      cp -R hrms/public $out/hrms
      cp -R hrms/www $out/hrms
      cp -R node_modules $out/hrms/public

      cp -R ${roster}/public/roster $out/hrms/public
      cp -R ${frontend}/public/frontend $out/hrms/public

      cp -R ${roster}/public/www/* $out/hrms/www
      cp -R ${frontend}/public/www/* $out/hrms/www

      runHook postInstall
    '';
  });

in
buildPythonPackage rec {
  inherit
    (extractFrappeMeta src)
    pname
    version
    format
    ;

  inherit src;

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  postFixup = ''
    runHook preInstall

    cp -R ${hrms}/hrms/public/* $out/${python.sitePackages}/hrms/public
    cp -R ${hrms}/hrms/www/* $out/${python.sitePackages}/hrms/www

    runHook postInstall
  '';

  # pythonImportsCheck = ["hrms"];

  meta = with lib; {
    description = "Open Source HR & Payroll Software";
    homepage = "https://github.com/frappe/hrms";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [blaggacao];
  };
}
