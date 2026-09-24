/*
Flake `checks`: NixOS VM tests exercising the exported `nixosModules`
with a minimal, self-contained `services.frappe` declaration.

Unlike tests/nixos-tests.nix (which layers the `testrig` mixin and runs the
full frappe unit-test suite), these only assert that the plain module — as a
downstream user would declare it — brings up a working site.
*/
{
  nixpkgs,
  system,
  pkgs,
  nixos,
}: let
  nixos-lib = import (nixpkgs + /nixos/lib) {inherit system;};

  project = "minimal";
  site = "frappe.local";

  /*
  Build a VM test for a site running the given frappe apps.

  apps: the app packages (besides frappe) to make available on the server
  */
  mkSiteTest = {
    name,
    apps ? [],
    description,
  }: let
    appNames = ["frappe"] ++ map (app: app.pname) apps;
  in
    (nixos-lib.runTest {
      inherit name;
      _file = ./checks.nix;
      skipLint = true;
      hostPkgs = nixpkgs;

      nodes.machine = {
        imports = [nixos.frappix];

        # the frappix-overlaid package set (provides pkgs.frappix.*)
        nixpkgs = {inherit pkgs;};
        virtualisation = {
          # we don't do any nix build inside the test vm
          writableStore = false;
          cores = 4;
          memorySize = 4096; # MB
        };
        # no nix inside the VM: avoids the qemu-vm `register-nix-paths`
        # unit choking on the read-only 9p store
        nix.enable = false;

        # The minimal declaration a downstream consumer needs.
        services.frappe = {
          enable = true;
          inherit project apps;
          sites.${site} = {
            domains = [site];
            apps = appNames;
          };
          adminPassword = pkgs.writeText "admin-password" "admin";
          gunicorn_workers = 1;
        };

        # Serve plain http: the module defaults to forceSSL (ACME) which
        # the sandboxed VM cannot satisfy.
        services.nginx.virtualHosts.${site}.forceSSL = false;

        # Let the in-VM client resolve the site's domain.
        networking.hosts."127.0.0.1" = [site];
      };

      testScript =
        # python
        ''
          from datetime import timedelta

          machine.start()

          # installing + migrating a site is slow on a small VM
          setup_timeout = timedelta(minutes=45)

          with subtest("Site is installed"):
              machine.wait_for_unit("${project}-setup-${site}.target", timeout=setup_timeout)
              machine.succeed("test -d /var/lib/${project}/sites/${site}")

          with subtest("Main project target is reached"):
              machine.wait_for_unit("${project}.target", timeout=setup_timeout)

          with subtest("Web server answers over nginx"):
              machine.wait_for_unit("nginx.service")
              machine.wait_until_succeeds(
                  "curl -fsS http://${site}/api/method/ping | grep -q pong",
                  timeout=timedelta(minutes=5),
              )

          with subtest("Login works with the declared admin password"):
              machine.succeed(
                  "curl -fsS -c /tmp/cookies -X POST http://${site}/api/method/login"
                  " -H 'Content-Type: application/json'"
                  " -d '{\"usr\":\"Administrator\",\"pwd\":\"admin\"}'"
                  " | grep -q 'Logged In'"
              )

          with subtest("All declared apps are installed on the site"):
              versions = machine.succeed(
                  "curl -fsS -b /tmp/cookies"
                  " http://${site}/api/method/frappe.utils.change_log.get_versions"
              )
              for app in ${builtins.toJSON appNames}:
                  assert f'"{app}"' in versions, f"{app} not installed on ${site}: {versions}"

          with subtest("No unit failed and frappe units logged no errors"):
              machine.fail("systemctl --failed --quiet | grep -q .")
              machine.fail(
                  "journalctl --no-pager -u '${project}-*'"
                  " | grep -iE '\\berror\\b|traceback'"
              )
        '';
    })
    // {meta = {inherit description;};};
in {
  frappe-minimal = mkSiteTest {
    name = "frappe-minimal";
    description = "Minimal services.frappe declaration through nixosModules.frappix";
  };
  erpnext = mkSiteTest {
    name = "erpnext";
    apps = [pkgs.frappix.erpnext];
    description = "services.frappe with erpnext declared in the site's apps";
  };
}
