let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.src) pkgs nixos;
  inherit (inputs.nixpkgs) lib;

  # matches the testrig's `services.frappe.project` / `networking.domain`
  project = "TestProject";
  site = "erp.frx.localhost";
  nixos-lib = import (nixpkgs + /nixos/lib) {inherit (nixpkgs) system;};

  defaults = {
    nixpkgs = {inherit pkgs;};
    virtualisation = {
      # we don't do any nix build inside the test vm
      writableStore = false;
      cores = 2;
      # diskSize = 8000; # MB
      memorySize = 4096; # MB
      forwardPorts = [
        {
          guest.port = 80;
          host.port = 8080;
        }
        {
          guest.port = 443;
          host.port = 4433;
        }
      ];
    };
    imports = [
      nixos.testrig
      nixos.frappix
    ];
  };

  # the testrig's TLS is a self-signed wildcard and its ipv6 listener is not
  # exercised; pin curl to ipv4 + http/1.1 so the checks only observe frappe
  curl = "curl -k -s --http1.1 --resolve ${site}:80:127.0.0.1 --resolve ${site}:443:127.0.0.1";

  mkTest = {
    name,
    description,
    # services.frappe overrides for the variant under test
    frappe ? {},
    # apps expected on the site, in addition to frappe
    apps ? [],
    # further python test script, run once the site is up
    extraScript ? "",
  }:
    (nixos-lib.runTest {
      inherit name;
      _file = ./nixos-tests.nix;
      skipLint = true;
      defaults =
        defaults
        // {
          services.frappe =
            frappe
            // lib.optionalAttrs (apps != []) {
              sites.${site}.apps = lib.mkForce (["frappe"] ++ apps);
            };
        };
      hostPkgs = nixpkgs;
      nodes = {
        runnerA = {};
        # runnerB = {};
        # runnerC = {};
        # runnerD = {};
      };
      testScript =
        # python
        ''
          start_all()

          with subtest("Wait for machines to reach target"):
              for m in machines:
                  m.wait_for_unit("${project}.target")

          with subtest("Wait for site to become reachable"):
              for m in machines:
                  m.wait_until_succeeds('test $(${curl} -L -o /dev/null -w %{http_code} http://${site}) = 200', timeout=120)
                  assert '"pong"' in m.succeed("${curl} https://${site}/api/method/ping")

          with subtest("Apps are installed on the site"):
              for m in machines:
                  installed = m.succeed("bench --site ${site} list-apps")
                  print(installed)
                  for app in ${builtins.toJSON (["frappe"] ++ apps)}:
                      assert app in installed, f"{app} not installed on ${site}"

          ${extraScript}
        '';
    })
    // {
      meta.description = description;
    };
in {
  nixos-tests = mkTest {
    name = "frappe-test-nixos";
    description = "The frappix vm-based test suite using nixos modules";
    extraScript =
      # python
      ''
        with subtest("Run the unit test suite"):
            total_builds = len(machines)
            for idx, m in enumerate(machines):
                print("bench run-parallel-tests for ", m)
                stdout = m.succeed(f"bench run-parallel-tests --build-number {idx+1} --total-builds {total_builds}")
                print(stdout)
      '';
  };

  nixos-tests-v16 = mkTest {
    name = "frappe-v16-test-nixos";
    description = "Boot the nixos module with frappe v16 and erpnext v16";
    frappe = {
      package = pkgs.frappix.frappe-v16;
      apps = [pkgs.frappix.erpnext-v16];
    };
    apps = ["erpnext"];
    extraScript =
      # python
      ''
        with subtest("Installed versions are v16"):
            for m in machines:
                installed = m.succeed("bench --site ${site} list-apps")
                assert "frappe  16." in installed, installed
                assert "erpnext 16." in installed, installed

        with subtest("Background workers process jobs on rq 2.x"):
            for m in machines:
                # exits non-zero only because `bench execute` cannot json-dump the returned rq Job
                m.execute("bench --site ${site} execute frappe.enqueue --kwargs \"{'method': 'frappe.ping', 'queue': 'short'}\"")
                m.wait_until_succeeds("journalctl -u ${project}-worker-short --no-pager | grep -q \"Successfully completed .*job_name='frappe.ping'\"", timeout=120)

        with subtest("erpnext's banking frontend is served"):
            for m in machines:
                code = m.succeed("${curl} -o /dev/null -w %{http_code} https://${site}/assets/erpnext/banking/index.html").strip()
                assert code == "200", code
      '';
  };
}
