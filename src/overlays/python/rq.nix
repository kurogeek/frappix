{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,

  # build-system
  hatchling,

  # dependencies
  click,
  redis,

  # tests
  psutil,
  pytestCheckHook,
  redisTestHook,
  sentry-sdk,
}:

buildPythonPackage rec {
  pname = "rq";
  version = "1.6.2";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rq";
    repo = "rq";
    tag = "v${version}";
    hash = "sha256-8uhCV4aJNbY273jOa9D5OlgEG1w3hXVncClKQTO9Pyk=";
  };

  build-system = [ hatchling ];

  dependencies = [
    click
    redis
  ];

  nativeCheckInputs = [
    psutil
    pytestCheckHook
    redisTestHook
    sentry-sdk
  ];

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    # https://github.com/rq/rq/commit/fd261d5d8fc0fe604fa396ee6b9c9b7a7bb4142f
    "test_clean_large_registry"
    "test_serializer_and_queue_argument"
    "test_worker_class_argument"
    "test_worker_pool_burst_and_num_workers"
    "test_cli_flag"
    "test_failure_capture"
    "test_run_access_self"
    "test_run_empty_queue"
    "test_run_scheduled_access_self"
    "test_handle_exception_handles_non_ascii_in_exception_message"
  ];

  pythonImportsCheck = [ "rq" ];

  meta = with lib; {
    description = "Library for creating background jobs and processing them";
    homepage = "https://github.com/nvie/rq/";
    changelog = "https://github.com/rq/rq/releases/tag/${src.tag}";
    license = licenses.bsd2;
    maintainers = with maintainers; [ mrmebelman ];
  };
}
