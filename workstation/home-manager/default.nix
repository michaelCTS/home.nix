{ config, pkgs, lib, ... }:

let
  specificImport = if builtins.pathExists "${./.}/specific"
    then [ ./specific ] else [];
  supervisorConf = ".config/supervisor/daemon.conf";
  supervisorConfDir = ".config/supervisor/conf.d";
in
{
  imports = [
    ./common
    ./ssh.nix
    ./vnc.nix
  ] ++ specificImport ;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "23.05"; # Please read the comment before changing.

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

  # TODO make it possible to generate this with nix
  home.file.supervisord = {
    enable = true;
    target = supervisorConf;
    text = ''
[supervisord]
pidfile = %(ENV_HOME)s/.cache/supervisord/pid
environment = SSH_AUTH_SOCK=%(ENV_HOME)s/.cache/ssh-agent.sock

[unix_http_server]
file = %(ENV_HOME)s/.cache/supervisord/http.sock
[supervisorctl]
serverurl=unix://%(ENV_HOME)s/.cache/supervisord/http.sock
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[include]
files = %(ENV_HOME)s/${supervisorConfDir}/*.conf
  '';
  };
}
