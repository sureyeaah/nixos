{ pkgs, ... }: {
  nix.settings.substituters = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];
  nix.settings.trusted-public-keys = [
    "https://hydra.iohk.io"
  ];
}
