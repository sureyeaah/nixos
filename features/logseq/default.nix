{pkgs, ...}:
let
    logseq = import ./build.nix pkgs;
in {
        environment.systemPackages = [ logseq ];
}
