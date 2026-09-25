let
  project = "TestProject";
  sslPath = "/etc/nginx/ssl";
  # minica --domains '*.frx.localhost,frx.localhost'
  ca = ./test-ca.pem;
  cert = ./test-cert.pem;
  key = ./test-key.pem;
in
  {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib.modules) mkDefault;
    mkTestOverride = lib.modules.mkVMOverride;

    cfg = config.services.frappe;
    test-deps = lib.flatten (lib.catAttrs "test-dependencies" cfg.apps);
    penv-test = cfg.package.pythonModule.buildEnv.override {extraLibs = cfg.apps ++ test-deps;};
  in {
    options.services.nginx.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        sslTrustedCertificate =
          lib.mkDefault
          config.environment.etc."ssl/certs/ca-certificates.crt".source;
        sslCertificate = lib.mkDefault "${sslPath}/cert.pem";
        sslCertificateKey = lib.mkDefault "${sslPath}/key.pem";
        enableACME = mkTestOverride false;
      });
    };
    config = {
      virtualisation.vmVariant.virtualisation = {
        memorySize = 4096;
        cores = 2;
        graphics = false;
        forwardPorts = [
          {
            guest.port = 80;
            host.port = 80;
          }
          {
            guest.port = 443;
            host.port = 443;
          }
        ];
      };
      users.mutableUsers = false;
      networking = {
        firewall.enable = false;
        # chrome and other browsers don't show a warning screen for self signed certs on localhost
        domain = mkTestOverride "frx.localhost";
        hostName = mkTestOverride "testhost";
        # workarround
        hosts = mkTestOverride {
          # "127.0.0.1" = ["frx.localhost" "localhost"];
          # "::1" = ["frx.localhost" "localhost"];
        };
      };
      security.acme.acceptTerms = mkTestOverride false;
      environment.etc."${cfg.project}/admin-password".text = "admin";
      security.pki.certificateFiles = [ca];
      systemd.tmpfiles.rules = [
        "d ${sslPath} 744 ${config.services.nginx.user} ${config.services.nginx.group}"
        # bench commands run from the test shell (e.g. the test runner) discover apps
        # and assets via the file system, outside the frappe units' mount namespaces.
        # Emplace the links before any unit turns these paths into (empty) bind mount
        # points; the units' BindReadOnlyPaths resolve through the links unharmed.
        "d  ${cfg.benchDirectory}/sites 0755 ${cfg.project} ${cfg.project} -"
        "L+ ${cfg.benchDirectory}/sites/assets   - - - - ${cfg.combinedAssets}/share/sites/assets"
        "L+ ${cfg.benchDirectory}/sites/apps.txt - - - - ${cfg.combinedAssets}/share/sites/apps.txt"
        "L+ ${cfg.benchDirectory}/apps           - - - - ${cfg.combinedAssets}/share/apps"
      ];
      services.getty.autologinUser = "root";
      users.users.root.password = "root";
      security.sudo = {
        enable = mkTestOverride true;
        wheelNeedsPassword = false;
      };
      systemd.services."create-wildcard-frx.localhost-cert" = {
        description = "Create a wildcard certificate for *.frx.localhost";
        script = ''
          cp ${cert} cert.pem
          cp ${key} key.pem
          chmod 644 cert.pem
          chmod 640 key.pem
        '';

        wantedBy = ["multi-user.target" "nginx.service"];
        wants = ["systemd-tmpfiles-setup.service"];
        after = ["systemd-tmpfiles-setup.service"];
        unitConfig = {
          Before = ["multi-user.target" "nginx.service"];
          ConditionPathExists = "!${sslPath}/cert.pem";
        };

        serviceConfig = {
          User = config.services.nginx.user;
          Type = "oneshot";
          WorkingDirectory = sslPath;
          RemainAfterExit = true;
        };
      };
      systemd.services."${cfg.project}-config-setup" = {
        unitConfig.AssertPathIsReadWrite = mkTestOverride null;
        script = let
          settingsFormat = pkgs.formats.json {};
          commonSiteConfigFile = settingsFormat.generate "common_site_config.json" cfg.commonSiteConfig;
        in
          mkTestOverride
          # bash
          ''
            set -euo pipefail
            # some tests need it to be writable, e.g. `test_set_global_conf`
            cp -f ${commonSiteConfigFile} ./common_site_config.json
            chmod 775 ./common_site_config.json
          '';
      };

      services.frappe = {
        project = mkDefault project;
        enable = true;
        adminPassword = mkTestOverride "/etc/${cfg.project}/admin-password";
        gunicorn_workers = mkTestOverride 1;
        penv = mkTestOverride penv-test;
        commonSiteConfig = {
          default_site = "erp.${config.networking.domain}";
          allow_tests = true;
          # fake smtp setting for notification / email tests
          auto_email_id = "test@example.com";
          mail_server = "smtp.example.com";
          mail_login = "test@example.com";
          mail_password = "test";
          server_script_enabled = true;
          # not sure about these
          monitor = 1;
          redis_queue = "unix:///run/redis-${cfg.project}-queue/redis.sock";
          redis_cache = "unix:///run/redis-${cfg.project}-cache/redis.sock";
        };
        environment = {
          # python requests observes this, among others
          CURL_CA_BUNDLE = config.environment.etc."ssl/certs/ca-certificates.crt".source;
          # openssl-based librarise typically observe this
          SSL_CERT_FILE = config.environment.etc."ssl/certs/ca-certificates.crt".source;
        };
        sites = {
          "erp.${config.networking.domain}" = {
            domains = ["erp.${config.networking.domain}"];
            apps = ["frappe"];
          };
        };
      };
    };
  }
