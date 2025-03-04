{
  description = "Lorenzo's Blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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
          nodePackages.sass
          hugo
          wrangler
          libwebp
        ];
      };
    }
  );
}
