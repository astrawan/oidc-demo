{
  description = "Simple devshell flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          docker-compose-language-service
          getent
          markdown-toc
          markdownlint-cli2
          yaml-language-server
        ];

        shellHook = ''
          runHook preShellHook
          SHELL="$(getent passwd $USER | awk -F: '{print $NF}')";
          SHELL="$SHELL" $SHELL && runHook postShellHook
        '';
      };
    };
}
