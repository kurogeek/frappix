{
  appSources,
  lib,
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  python,
  extractFrappeMeta,
  stdenv,
  applyPatches,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs,
  yarn,
  frappe,
}: let
  inherit (appSources.erpnext-v16) version;

  patchedSrc = applyPatches {
    name = "patched-erpnext-v16";
    inherit (appSources.erpnext-v16) src;
    patches = [
      ./erpnext-v16-0001-lock-axios-deps.patch
      ./erpnext-v16-0002-banking-proxy-config-optional.patch
    ];
  };

  # React/Vite app under ./banking; upstream's `yarn build` emits into
  # ../erpnext/public/banking and ../erpnext/www/banking.html
  banking = stdenv.mkDerivation (finalAttrs: {
    pname = "erpnext-banking";
    inherit version;

    src = "${patchedSrc}/banking";

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-pfCimPveBxChsE6DYRE6ORP/X/riIYgmtmNaTfnspfk=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      mkdir -p ../erpnext/public/banking ../erpnext/www
      yarn --offline build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/erpnext/public $out/erpnext/www
      cp -R ../erpnext/public/banking $out/erpnext/public
      cp ../erpnext/www/banking.html $out/erpnext/www

      runHook postInstall
    '';
  });
in
  buildPythonPackage rec {
    inherit
      (extractFrappeMeta appSources.erpnext-v16.src)
      pname
      version
      format
      ;

    # the root package.json's `build` script only delegates to ./banking,
    # which is built separately above; here we only need `node_modules`
    src = stdenv.mkDerivation (finalAttrs: {
      pname = "erpnext_";
      src = patchedSrc;
      inherit version;

      yarnOfflineCache = fetchYarnDeps {
        yarnLock = "${finalAttrs.src}/yarn.lock";
        hash = "sha256-25VPD0K192AMYRmOHhMao6I3As/KW9LvulB/6zK2Wbk=";
      };

      nativeBuildInputs = [
        nodejs
        yarn
        yarnConfigHook
      ];

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -R . $out
        cp -R ${banking}/erpnext/public/banking $out/erpnext/public
        cp ${banking}/erpnext/www/banking.html $out/erpnext/www

        runHook postInstall
      '';
    });

    inherit (appSources.erpnext-v16) passthru;

    nativeBuildInputs = [
      pythonRelaxDepsHook
      flit-core
    ];

    propagatedBuildInputs = with python.pkgs; [
      barcodenumber
      googlemaps
      holidays
      mt-940
      pdfplumber
      plaid-python
      pypng
      # temporary fix until https://github.com/NixOS/nixpkgs/pull/556318 is merged
      (python-youtube.overrideAttrs {disabledTests = ["test_parse_response"];})
      rapidfuzz
      unidecode
    ];

    pythonRelaxDeps = [
      "rapidfuzz"
      "python-youtube"
      "unidecode"
      "pypng"
      "holidays"
    ];

    nativeCheckInputs = [frappe];

    pythonImportsCheck = ["erpnext"];

    meta = with lib; {
      description = "Free and Open Source Enterprise Resource Planning (ERP)";
      homepage = "https://github.com/frappe/erpnext";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [blaggacao];
    };
  }
