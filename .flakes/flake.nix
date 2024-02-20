# Resources
# ---
# https://github.com/NixOS/templates/blob/2d6dcce2f3898090c8eda16a16abdff8a80e8ebf/c-hello/flake.nix
#
# According to https://nixos.wiki/wiki/CUDA, it is recommended to enable the cuda-maintainers cachix instance, i.e., 
# add 
# ```
# nix.settings = {
#   substituters = [
#     "https://cuda-maintainers.cachix.org/"
#   ];
#   trusted-public-keys = [
#     "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
#   ];
# };
# ```
# to /etc/nixos/configuration.nix.

{
  description = "A framework for automatic performance optimization of DNN training and inference";

  nixConfig.bash-prompt-prefix = "(ff) ";

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
