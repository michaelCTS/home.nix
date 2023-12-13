# Options common to all configurations

{ config, pkgs, ...}:

{

  home.packages = with pkgs; [
    bat
    curl
    fd
    htop
    lazygit
    ripgrep
    wget
  ];

}
