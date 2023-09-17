{ buildPythonPackage, llvmPackages, writeText, python3Packages }:

# from https://codeberg.org/Uli/nix-things/src/commit/776519e382c81b136c1d0b10d8c7b52b4acb9192/overlays/cq/python/libclang-python.nix

let
  libclang = llvmPackages.libclang;
in
buildPythonPackage rec {
  pname = "libclang";
  version = libclang.version;

  src = libclang.src;

  nativeBuildInputs = with python3Packages; [ 
    setuptools
  ];

  propagatedBuildInputs = [
    llvmPackages.libclang
  ];

  postUnpack =
    let
      pyproject_toml = writeText "pyproject.toml" ''
        [build-system]
        requires = [
            "setuptools>=42",
            "wheel"
        ]
        build-backend = "setuptools.build_meta"
      '';
      setup_cfg = writeText "setup.cfg" ''
        [metadata]
        name = clang
        version = ${libclang.version}

        [options]
        packages = clang
      '';
    in
    ''
      sourceRoot="$sourceRoot/bindings/python"
      for _src in "${pyproject_toml}" "${setup_cfg}"; do
        cp "$_src" "$sourceRoot/$(stripHash "$_src")"
      done
    '';

  format = "pyproject";
}
