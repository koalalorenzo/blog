{
  description = "Lorenzo's Blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (msystem:
    let
      pkgs = import nixpkgs { system = "${msystem}"; config.allowUnfree = true; };
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          coreutils
          git
          gnumake
          gnupg
          hugo
          libwebp
          nodePackages.sass
          nodejs_24
          wrangler
        ];
      };
    }
  );
}
