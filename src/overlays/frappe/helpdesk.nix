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
}: let
  src = applyPatches {
    inherit (appSources.helpdesk) src;
    name = "patched-helpdesk";
    patches = [
      ./helpdesk-0001-build-socket-port-is-reverse-proxied.patch
      ./helpdesk-0002-lock-tailwindcss-rtl.patch
    ];
  };
  inherit (appSources.helpdesk) version;

  # The desk frontend links `@framework/ui` from `../../frappe/ui` and that
  # package reaches further into the frappe tree (e.g. `frappe/geo/*.json`),
  # i.e. it expects the bench layout `apps/frappe` next to `apps/helpdesk`.
  # Its vite plugin resolves `@framework/ui`'s own node dependencies against
  # the host frontend, so frappe's `node_modules` are not needed.
  frontend = stdenv.mkDerivation {
    pname = "helpdesk-frontend";
    inherit version;

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/desk/yarn.lock";
      hash = "sha256-hWi5wDhU3DvKKlG6SsSRVhPs1ByLP5CQNs6z76Cgrkk=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    unpackPhase = ''
      runHook preUnpack

      mkdir -p apps/helpdesk
      ln -s ${appSources.frappe.src} apps/frappe
      cp -R ${src}/. apps/helpdesk
      chmod -R u+w apps/helpdesk

      runHook postUnpack
    '';
    sourceRoot = "apps/helpdesk/desk";

    buildPhase = ''
      runHook preBuild

      # `yarn install --ignore-scripts` (yarnConfigHook) skips the
      # `postinstall: patch-package` script
      node_modules/.bin/patch-package

      npm run build

      runHook postBuild
    '';

    # vite writes into `../helpdesk/public/desk` and `../helpdesk/www/helpdesk/index.html`
    installPhase = ''
      runHook preInstall

      mkdir -p $out/public $out/www/helpdesk
      cp -R ../helpdesk/public/desk $out/public/desk
      cp ../helpdesk/www/helpdesk/index.html $out/www/helpdesk/index.html

      runHook postInstall
    '';
  };
in
  buildPythonPackage {
    inherit
      (extractFrappeMeta src)
      pname
      version
      format
      ;

    src = stdenv.mkDerivation {
      pname = "helpdesk_";
      inherit src version;
      installPhase = ''
        mkdir $out
        cp -R . $out
        cp -R ${frontend}/public/desk $out/helpdesk/public/desk
        cp ${frontend}/www/helpdesk/index.html $out/helpdesk/www/helpdesk/index.html
      '';
    };
    inherit (appSources.helpdesk) passthru;

    nativeBuildInputs = [
      pythonRelaxDepsHook
      flit-core
    ];

    propagatedBuildInputs = with python.pkgs; [
      textblob
    ];

    pythonRelaxDeps = [
      "textblob"
    ];

    # would require frappe, but since frappe is almost certainly customized,
    # we don't include it here
    # pythonImportsCheck = ["helpdesk"];

    meta = with lib; {
      description = "Open Source Customer Service Software";
      # `required_apps = ["telephony"]`: deploy together with `frappix.telephony`
      homepage = "https://github.com/frappe/helpdesk";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [];
    };
  }
