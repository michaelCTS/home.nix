{ config, pkgs, ...}:

let
  supervisorConfDir = ".config/supervisor/conf.d";
  sshAgentStart = pkgs.writeShellScript "ssh-agent-start" ''
    rm -f $HOME/.cache/ssh-agent.sock
    ${pkgs.openssh}/bin/ssh-agent -D -a $HOME/.cache/ssh-agent.sock
  '';
in
{

  home.packages = with pkgs; [
    openssh
  ];

  home.file.supervisord_ssh_agent = {
    enable = true;
    target = "${supervisorConfDir}/100_ssh_agent.conf";
    text = ''
[program:ssh-agent]
autostart = true
command = ${sshAgentStart}'';
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

}
