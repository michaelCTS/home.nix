{ config, pkgs, lib, ... }:

{
  imports = [
    ./vnc.nix
  ];
  home.username = lib.mkForce "user";
  home.homeDirectory = lib.mkForce "/home/user";
  home.packages = with pkgs; [
    dbeaver
    jetbrains.pycharm-professional
    konsole
    lunarvim
    xorg.xinit
  ];

  nixpkgs.config.allowUnfree = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
    . /home/user/.nix-profile/etc/profile.d/nix.sh
    '';
  };

  home.file.sshKey = {
    enable = true;
    source = ./ssh_keys/private;
    target = ".ssh/id_ed25519";
  };
  home.file.sshKeyPub = {
    enable = true;
    source = ./ssh_keys/public;
    target = ".ssh/id_ed25519.pub";
  };
  # TODO: setup session
  # https://github.com/TurboVNC/turbovnc/blob/b4fd6ae2a15f08c6052918d29511dffe37e4dae3/unix/turbovncserver.conf.in#L4
  # Use wm = $pathToSession.desktop
  # wm = ${pkgs.icewm}/share/xsessions/icewm-session.desktop
  home.file.vncConfig = {
    enable = true;
    target = ".vnc/turbovncserver.conf";
    text = ''
geometry=1920x1080
    '';
  };

}
