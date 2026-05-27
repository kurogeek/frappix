# adopted from: https://git.pub.solar/axeman/erpnext-nix/src/branch/main/node/mk-app.nix
{
  nodejs,
  yarn,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  lib,
  stdenv,
}: {
  pname,
  src,
  version,
  yarnHash,
  ...
}: let
  yarnLock = "${src}/yarn.lock";
  hasLock = builtins.pathExists yarnLock;
  pjson = lib.importJSON (src + /package.json);
  runBuild = pjson ? scripts && pjson.scripts ? build && pname != "frappe";

  offlineCache = lib.optionalAttrs hasLock (fetchYarnDeps {
    inherit src;
    hash = yarnHash; # populate with `nix-prefetch` or leave empty to get the hash error
  });
in
  stdenv.mkDerivation {
    pname = pname + "_";
    inherit src version;

    yarnOfflineCache = lib.optionalString hasLock offlineCache;

    nativeBuildInputs =
      lib.optionals hasLock [
        yarnConfigHook
      ]
      ++ lib.optionals (hasLock && runBuild) [
        yarnBuildHook
      ]
      ++ [
        nodejs
        yarn
      ];

    # yarnConfigHook replaces: yarn config set yarn-offline-mirror,
    # fixup_yarn_lock, and yarn install --offline
    # It sets HOME, points yarn at the offline cache, and runs yarn install.
    # No configurePhase or buildPhase boilerplate needed for those steps.

    # Only needed if runBuild is false but hasLock is true —
    # yarnBuildHook runs `yarn build` automatically when included.
    buildPhase = lib.optionalString (hasLock && !runBuild) ''
      echo "Skipping yarn build for $pname"
    '';

    installPhase = ''
      mkdir -p $out
      cp -R . $out
    '';
  }
