{ lib
, aiodns
, asynctest
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pythonOlder
, tldextract
, whodap
}:

buildPythonPackage rec {
  pname = "asyncwhois";
  version = "0.4.0";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "pogzyb";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-yJ+AHUyzAl8lRcKcLfMJ8InhV0LVUK+Neb5ngQOwFTM=";
  };

  propagatedBuildInputs = [
    aiodns
    tldextract
    whodap
  ];

  checkInputs = [
    asynctest
    pytestCheckHook
  ];

  # Disable tests that require network access
  disabledTests = [
    "test_pywhois_aio_get_hostname_from_ip"
    "test_pywhois_get_hostname_from_ip"
    "test_pywhois_aio_lookup_ipv4"
    "test_not_found"
    "test_aio_from_whois_cmd"
    "test_aio_get_hostname_from_ip"
    "test_from_whois_cmd"
    "test_get_hostname_from_ip"
    "test_whois_query_run"
  ];

  pythonImportsCheck = [ "asyncwhois" ];

  meta = with lib; {
    description = "Python module for retrieving WHOIS information";
    homepage = "https://github.com/pogzyb/asyncwhois";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ fab ];
  };
}
