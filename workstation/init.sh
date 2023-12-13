#!/usr/bin/env bash
set -eux

if [[ -n "${SSH_CONNECTION:-}" ]] ; then
  # Do stuff on the workstation

  # Ensure /nix is a bind mount
  mkdir -p ${HOME}/nix

  if ! mountpoint -q /nix ; then
    sudo mkdir -p /nix
    sudo mount --bind ${HOME}/nix /nix
  fi

  # Install nix if necessary
  if ! type -t nix ; then
    echo "Installing nix"
    # ensure nix installer can write into .profile
    rm ~/.profile
    touch ~/.profile
    rm ~/.bashrc
    touch ~/.bashrc
    rm ~/.bash_profile
    touch ~/.bash_profile

    # Clean up nix state as it probably doesn't exist anymore after a restart
    rm -rf ~/.local/state/nix

    # Install nix
    sh <(curl -L https://nixos.org/nix/install) --no-daemon

    if ! grep nix ~/.bashrc &> /dev/null ; then
      echo '. /home/user/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc
    fi

    source ~/.bashrc # put nix into env
    nix-channel --update
  fi

  # Install home-manager
  if ! type -t home-manager ; then
    echo "Installing home-manager"
    rm -rf ~/.config/home-manager
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
  fi

else

  # Execute remotely on workstation
  function _e(){
    ssh workstation "$@"
  }
  # copy script to workstation and execute it
  scp "${0}" workstation:init.sh

  # Execute init script remotely
  _e chmod +x init.sh
  _e ./init.sh

  # Setup home-manager
  _e mkdir -p .config
  _e rm -rf .config/home-manager
  scp -r home-manager/ workstation:.config/home-manager
  scp -r ../common/ workstation:.config/home-manager/common
  _e home-manager switch -b backup
fi

