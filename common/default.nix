# Options common to all configurations

{ config, pkgs, ...}:

{

  home.packages = with pkgs; [
    bat
    curl
    fd
    htop
    lazygit
    nix-index # Allows finding commands in nix packages
    ripgrep
    wget
  ];

}
