{
  nixConfig = {
    bash-prompt-prefix = "(ff) ";
  };
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: 
    let 
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in 
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          export PATH="$HOME/ff/.scripts/:$PATH"
        '';
        buildInputs = (with pkgs; [
          gh
          python3
          jq
        ]) ++ (with pkgs.python3Packages; [
          gitpython
          pygithub
          toml
        ]);
      };
    }
  );
}
# vim: set tabstop=2 shiftwidth=2 expandtab:
