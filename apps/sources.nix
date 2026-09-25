let
  inherit (builtins) readDir;
  inherit (inputs.nixpkgs) lib applyPatches replaceVars;

  fileIsNix = basename: type: type == "regular" && lib.hasSuffix ".nix" basename;

  loadPath = path: name: _: import (lib.path.append path name);

  sourceDirectoryEntries = path: lib.mapAttrs (loadPath path) (lib.filterAttrs fileIsNix (readDir path));

  sanitizeKey = name: attrs: lib.nameValuePair (lib.removeSuffix ".nix" name) attrs;

  # Every frappe source tree gets two layers of patches:
  #  1. workdirsrc: patches that must be present in all derived trees
  #     (also used as the bench workdir source)
  #  2. deploysrc: patches that reference the (patched) workdir absolutely
  patchFrappe = name: udsPatch: attrs: let
    workdirsrc = applyPatches {
      name = "${name}-source-1";
      inherit (attrs) src;
      patches = [
        # This mariadb has passwordless root access
        # for the current user
        udsPatch
      ];
    };
    deploysrc = applyPatches {
      name = "${name}-source-2";
      src = workdirsrc;
      patches = [
        # make the relative path to the generator script absolute
        # but reference the already patched version to work with uds
        (replaceVars ./sources/frappe-website-generator.patch {
          frappe = workdirsrc;
        })
      ];
    };
  in
    attrs
    // {
      src = deploysrc;
      passthru = (attrs.passthru or {}) // {inherit workdirsrc;};
    };

  applyInputPatches = name: attrs:
    {
      frappe = patchFrappe name ./sources/frappe-uds-current-user-v15.patch attrs;
      frappe-v16 = patchFrappe name ./sources/frappe-uds-current-user-v16.patch attrs;
    }
    .${
      name
    }
    or attrs;
in
  lib.mapAttrs applyInputPatches (lib.mapAttrs' sanitizeKey (sourceDirectoryEntries ./sources))
