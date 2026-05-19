{ pkgs, ... }:

# HACK: test-only issues in the mcp-nixos Python dependency tree,
# scoped via overrideScope to avoid affecting the global nixpkgs instance.
#
# 1. aioboto3-15.5.0 test suite fails against aiobotocore-3.1.1 with
#    "Duplicate 'Server' header" errors in test_dynamo.py. The package
#    itself is functional; only the tests are broken.
#    TODO: remove once nixpkgs fixes the aioboto3 test suite upstream.
#
# 2. py-key-value-aio lists python3Packages.duckdb in nativeCheckInputs;
#    duckdb depends on pyarrow -> arrow-cpp which is globally broken in
#    nixpkgs, causing evaluation to fail on all platforms (including
#    darwin). Stripping the check inputs prevents the broken evaluation
#    path. mcp-nixos does not use duckdb at runtime.
#    TODO: remove once arrow-cpp is fixed upstream in nixpkgs.
#
# 3. fastmcp has a large test suite that takes a long time to run and
#    is not needed for the mcp-nixos functionality.
#    TODO: remove once fastmcp tests are fast enough to be acceptable.
#
# 4. mcp-nixos TestStoreReadTextFile::test_read_text_file picks the first
#    text file from /nix/store and asserts "Error" not in the content. This
#    is environment-dependent and fails when the first file (e.g.
#    highlight.pack.js) legitimately contains the word "Error" in its source.
#    The overrideScope approach cannot disable mcp-nixos's own tests because
#    pkgs.mcp-nixos IS python3Packages.mcp-nixos — overriding it inside its
#    own scope is circular and has no effect. The fix is to apply
#    overridePythonAttrs on the final derivation after .override { }.
#    TODO: remove once the upstream test uses a controlled fixture file.
(pkgs.mcp-nixos.override {
  python3Packages = pkgs.python3Packages.overrideScope (
    _final: prev: {
      aioboto3 = prev.aioboto3.overridePythonAttrs (_old: {
        doCheck = false;
      });
      fastmcp = prev.fastmcp.overridePythonAttrs (_: {
        doCheck = false;
      });
      py-key-value-aio = prev.py-key-value-aio.overridePythonAttrs (_: {
        nativeCheckInputs = [ ];
        doCheck = false;
      });
    }
  );
}).overridePythonAttrs
  (_: {
    doCheck = false;
  })
