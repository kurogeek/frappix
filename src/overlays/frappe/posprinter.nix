{
  buildPythonPackage,
  pythonRelaxDepsHook,
  flit-core,
  mkAssets,
  fetchFromGitea,
}:
let
  version = "0.0.1";
  posprinterSrc = fetchFromGitea {
    domain = "git.b4l.co.th";
    owner = "newedge";
    repo = "posprinter";
    rev = "7a3ca92d4c3c35623e7f2478914718b88b2bc279";
    sha256 = "sha256-Bw8aFljctgb3b+KywwU0l22cGf2lOqvX6ompucemo1A=";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "posprinter";
  inherit version;

  pyproject = true;

  src = mkAssets {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    src = posprinterSrc;
    yarnHash = "sha256-UFAEybvxz7uW26bz6JQ0VxQu8Tw08CdH7FjV6KaEfOk=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
    flit-core
  ];
})

