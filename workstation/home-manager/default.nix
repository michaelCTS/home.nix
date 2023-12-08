{ config, pkgs, lib, ... }:

let
  specificImport = if builtins.pathExists "${./.}/specific"
    then [ ./specific ] else [];
  supervisorConf = ".config/supervisor/daemon.conf";
  supervisorConfDir = ".config/supervisor/conf.d";
in
{
  imports = [
    ./vnc.nix
  ] ++ specificImport ;
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
  home.file.supervisord_ssh_agend = {
    enable = true;
    target = "${supervisorConfDir}/100_ssh_agent.conf";
    text = ''
[program:ssh-agent]
autostart = true
command = ${pkgs.openssh}/bin/ssh-agent -D -a %(ENV_HOME)s/.cache/ssh-agent.sock
  '';
  };

  home.sessionVariablesExtra = ''
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK=$HOME/.cache/ssh-agent.sock
    fi
  '';

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
