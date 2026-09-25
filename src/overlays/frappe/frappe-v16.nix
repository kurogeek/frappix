{
  appSources,
  lib,
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  python,
  pkgs,
  extractFrappeMeta,
  mkAssets,
}:
buildPythonPackage rec {
  inherit
    (extractFrappeMeta src)
    pname
    version
    format
    ;

  src = mkAssets {
    inherit (appSources.frappe-v16) src version;
    # mkAssets skips `yarn build` for frappe itself (built by `bench build`)
    pname = "frappe";
    yarnHash = "sha256-2BV8q92riHiVqXyaY7W9zh5m45DnvLag+t3xEphVWFo=";
  };

  passthru =
    appSources.frappe-v16.passthru
    // {
      packages = with pkgs; [
        mariadb
        restic
        wkhtmltopdf
        which # pdfkit detects wkhtmltopdf this way
        gzip # for manual backups from the frappe ui
        bash
        nodejs
        redis
      ];
      test-dependencies = with python.pkgs; [
        faker
        hypothesis
        responses
        freezegun
      ];
    };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];

  propagatedBuildInputs = with python.pkgs;
    [
      babel
      beautifulsoup4
      bleach-allowlist
      chardet
      click
      croniter
      cryptography
      cssutils
      distro
      duckdb
      email-reply-parser
      filelock
      filetype
      gitpython
      google-api-python-client
      google-auth
      google-auth-oauthlib
      gunicorn
      hiredis
      html5lib
      ipython
      jinja2
      ldap3
      markdown2
      markdownify
      markupsafe
      mysqlclient
      nh3
      num2words
      oauthlib
      openpyxl
      orjson
      passlib
      pdfkit
      phonenumbers
      pillow
      premailer
      psutil
      psycopg2 # -binary
      pyarrow
      pycountry
      pydantic
      pydyf
      pyjwt
      pymysql
      pyopenssl
      pyotp
      pypdf
      pypika
      pyqrcode
      python-dateutil
      pytz
      pyyaml
      rauth
      redis
      requests
      requests-oauthlib
      restrictedpython
      rq_2
      rsa
      semantic-version
      sentry-sdk
      sql_metadata
      sqlparse
      tenacity
      terminaltables
      traceback-with-variables
      typing-extensions
      vobject
      weasyprint
      websockets
      werkzeug
      whoosh
      xlrd
      xlsxwriter
      zxcvbn
    ]
    ++ passthru.packages;

  # upstream pins (almost) every dependency to an exact or compatible
  # release; nixpkgs moves independently, so relax them all
  pythonRelaxDeps = true;

  pythonRemoveDeps = [
    "psycopg2-binary"
  ];

  postInstall = ''
    mkdir -p $out/share
    install -m 0666 ${appSources.bench.src}/bench/config/templates/502.html  $out/share
    install -m 0666 ${appSources.bench.src}/bench/patches/patches.txt        $out/share
  '';

  # has no tests
  doCheck = false;

  pythonImportsCheck = ["frappe"];

  meta = with lib; {
    homepage = "https://github.com/frappe/frappe";
    description = "Low code web framework for real world applications, in Python and Javascript";
    changelog = "https://github.com/frappe/frappe/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
