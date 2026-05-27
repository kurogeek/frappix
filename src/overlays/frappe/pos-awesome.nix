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
    hash = "";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "pos-frontend";
    inherit version;

    src = "${src}/frontend";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-miHW6ix8EXrKp7dG1pBMfFs3l5r6jOYJveod6Cg15Ok=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      substituteInPlace $TMP/frontend/vite.config.js --replace-fail "../ppd/public/frontend" out/public/frontend
      substituteInPlace $TMP/frontend/package.json --replace-fail "../ppd/public/frontend" out/public/frontend
      substituteInPlace $TMP/frontend/package.json --replace-fail "../ppd/www" out/public/www

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

  ppd = stdenv.mkDerivation (finalAttrs: {
    pname = "ppd-assets";
    inherit version;

    inherit src;


    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-miHW6ix8EXrKp7dG1pBMfFs3l5r6jOYJveod6Cg15Ok=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/ppd/www

      cp -R ppd/public $out/ppd
      cp -R node_modules $out/ppd/public

      # should as well just remove
      ln -sf $out/ppd/public/node_modules/nanoid/bin/nanoid.cjs $out/ppd/public/node_modules/.bin/nanoid
      rm $out/ppd/public/node_modules/.bin/autoprefixer

      cp -R ${frontend}/public/frontend $out/ppd/public
      cp -R ${frontend}/public/www/* $out/ppd/www

      runHook postInstall
    '';
  });

in
buildPythonPackage  {

  pname = "ppd";
  version = version;
  format = "pyproject";

  src = stdenv.mkDerivation {
    pname = "ppd-main";
    inherit src version;
    installPhase = ''
      mkdir -p $out/ppd/www

      cp -R . $out
      cp -R ${ppd}/ppd/public/node_modules $out

      cp -R ${ppd}/ppd/public/frontend $out/ppd/public

      cp -R ${ppd}/ppd/www/ppd.html $out/ppd/www/
    '';
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  postFixup = ''
    runHook preInstall

    cp -R ${ppd}/ppd/public/* $out/${python.sitePackages}/ppd/public
    cp -R ${ppd}/ppd/www/* $out/${python.sitePackages}/ppd/www

    runHook postInstall
  '';

  meta = with lib; {
    license = licenses.agpl3Only;
    maintainers = with maintainers; [kurogeek];
  };
}
