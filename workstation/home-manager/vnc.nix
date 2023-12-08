{ config, pkgs, lib, ...}:

let
  py311 = pkgs.python311Packages;
  supervisord = "${py311.supervisor}/bin/supervisord";
  supervisorctl = "${py311.supervisor}/bin/supervisorctl";
  supervisorConf = ".config/supervisor/daemon.conf";
  supervisorConfDir = ".config/supervisor/conf.d";
  openboxAutostart = pkgs.writeShellScript "openbox-autostart" ''
    # Create menus
    mmaker --force -t Konsole OpenBox
    # Start panel
    tint2
  '';
in
{

  programs.bash.shellAliases = {
    sd = "${supervisord} -c ${config.home.homeDirectory}/${supervisorConf}";
    sctl = "${supervisorctl} -c ${config.home.homeDirectory}/${supervisorConf}";
  };

  home.packages = with pkgs; [
    # VNC
    novnc
    turbovnc
    # Window manager
    menumaker # Create menurs for certain window managers
    openbox
    tint2
  ];

  xdg.configFile."openbox-autostart" = {
    enable = true;
    source = openboxAutostart;
    target = "openbox/autostart.sh";
  };

  # TODO make it possible to generate this with nix
  home.file.supervisord_vnc = {
    enable = true;
    target = "${supervisorConfDir}/999_vnc.conf";
    text = ''

[program:turbovnc]
autostart = true
command = ${pkgs.turbovnc}/bin/vncserver -fg -xstartup openbox-session -log /dev/stdout :99
stopasgroup = true
killasgroup = true

[program:novnc]
autostart = true
command = ${pkgs.novnc}/bin/novnc --vnc 127.0.0.1:5999 --listen localhost:8080
'';
  };

}
