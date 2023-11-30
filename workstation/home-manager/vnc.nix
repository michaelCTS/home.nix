{ config, pkgs, lib, ...}:

let
  py311 = pkgs.python311Packages;
  supervisord = "${py311.supervisor}/bin/supervisord";
  supervisorctl = "${py311.supervisor}/bin/supervisorctl";
  supervisorConf = ".config/supervisor/daemon.conf";
in
{

  programs.bash.shellAliases = {
    sd = "${supervisord} -c ${config.home.homeDirectory}/${supervisorConf}";
    sctl = "${supervisorctl} -c ${config.home.homeDirectory}/${supervisorConf}";
  };

  # TODO make it possible to generate this with nix
  home.file.supervisord = {
    enable = true;
    target = supervisorConf;
    text = ''
[supervisord]
pidfile = %(ENV_HOME)s/.cache/supervisord/pid

[unix_http_server]
file = %(ENV_HOME)s/.cache/supervisord/http.sock
[supervisorctl]
serverurl=unix://%(ENV_HOME)s/.cache/supervisord/http.sock
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[program:turbovnc]
autostart = true
command = ${pkgs.turbovnc}/bin/vncserver -fg -xstartup ${pkgs.icewm}/bin/icewm
[program:novnc]
autostart = true
command = ${pkgs.novnc}/bin/novnc --vnc 127.0.0.1:5901 --listen localhost:8080
'';
  };

}
