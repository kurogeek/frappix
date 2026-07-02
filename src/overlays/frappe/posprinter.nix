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
    rev = "114828fca6dc87fb1d6704af40d144cc7d8d3ab6";
    sha256 = "sha256-LqgmdhPhV2OpX+ko7Ab1YsQzEIbGloS3sPltQTKWEwU=";
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

