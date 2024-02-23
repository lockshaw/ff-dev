{
  description = "A framework for automatic performance optimization of DNN training and inference";

  nixConfig = {
    bash-prompt-prefix = "(ff) ";
    extra-substituters = [
      "https://ff.cachix.org"
      "https://cuda-maintainers.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "ff.cachix.org-1:/kyZ0w35ToSJBjpiNfPLrL3zTjuPkUiqf2WH0GIShXM="
    ];
  };


  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: 
    let 
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # libclangPythonBindings = pkgs.python3Packages.callPackage ./pkgs/libclang.nix { };
    in 
      {
        # packages = {
        #   libclangPythonBindings = libclangPythonBindings;
        # };
        devShell = pkgs.mkShell.override {
          stdenv = pkgs.llvmPackages.libcxxStdenv;
        } {
          shellHook = ''
            export LOLPATH="${toString ./.}/.scripts:$PATH"
          '';
          buildInputs = (with pkgs; [
            clang-tools
            cmakeCurses
            llvmPackages.clang
            llvmPackages.stdenv
            ccache
            cudatoolkit
            cudaPackages.cuda_nvcc
            cudaPackages.cudnn
            cudaPackages.nccl
            cudaPackages.libcublas
            cudaPackages.cuda_cudart
            # cudaPackages.nvidia_driver
            gdb
            zlib
            pkg-config
            bashInteractive
            python3
            gh-markdown-preview
            plantuml
            libclang
            ruff
            gh
            jq
            compdb
            # self.packages.${system}.libclangPythonBindings
          ]) ++ (with pkgs.python3Packages; [
            ipython
            mypy
            python-lsp-server
            pylsp-mypy
            python-lsp-ruff
            pygithub
            sqlitedict
            frozendict
            black
            toml
          ]);
        };
      }
  );
}
# vim: set tabstop=2 shiftwidth=2 expandtab:
