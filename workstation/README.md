A quick way to setup the google workstation

# Requirements

## Workstation tunnel

In order to be able to connect to the workstation over SSH and take advantage of custom client configurations,
it's necessary to have a tunnel created by the google cloud sdk to the SSH port of the workstation.

```shell
gcloud alpha workstations start-tcp-tunnel 22 
        --local-host-port=localhost:2323 \
    $workstationName \
        --project=$workstationProject \
        --cluster=$workstationCluster \
        --config=$workstationConfig \
        --region=$workstationRegion \
```

## SSH 

### Config

To connect to the tunnel, some config is required.

Add this to `~/.ssh/config`

```
Host workstation
  Hostname localhost
  User user
  Port 2323
  LocalForward 5900 127.0.0.1:5999  # forward VNC port
  LocalForward 8080 127.0.0.1:8080   # forward noVNC port
```

To test that this works, run `ssh workstation` which should open an SSH connection to the workstation.

### Keys

These are for pulling stuff from Github.

Create (or copy) your SSH keys into  `./home-manager/ssh_keys/`.
Name the private key `private` and the corresponding public key `public`.

# Usage 

To setup the workstation, simply run `./init.sh`.
It will install `nix`, `home-manager`, and run `home-manager switch`.

You can now connect with `ssh workstation`.

## Remote Desktop

To start the remote desktop service on the workstation, just run 

```shell
sd
```

On the workstation.

### Browser (recommended)

It's recommended to use a remote desktop connection through the browser.
This is provided by `noVNC`.

Simply open your favorite browser at http://localhost:8080/vnc.html?host=127.0.0.1&port=8080


### Desktop client

If you have a fast connection, open your favorite RDC client and open vnc://localhost:5900

# Custom configuration

Should you want to customise your setup in ways that should end up in version control,
 use `home-manager/specific/default.nix`.
The entire folder is ignored by git.

All options can be found using the [home-manager option search][hm-search]

## Example

```nix

{ config, pkgs, ...}:

{

  programs.git = {
    enable = true;
    extraConfig = {
      user = {
        name = "Michael Vogel";
        email = "michael.vogel@cts.co";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      init.defaultBranch = "master";
    };
  };
}
```

# Tools used

 - [nix][nix]
 - [home-manager][hm]

[hm]: https://nix-community.github.io/home-manager/index.html
[hm-search]: https://mipmip.github.io/home-manager-option-search/
[nix]: https://nixos.org

