{
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
  };
  envconf = builtins.fetchGit {
    url = "https://github.com/jgardn3r/envconf";
  };
in {
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.jgardner = {
    # This should be the same value as `system.stateVersion` in
    # your `configuration.nix` file.
    home.stateVersion = "24.11";

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        source ${envconf}/.bashrc
        alias nixos-config="${envconf}/nixos/nixos-config.sh '${envconf}/nixos' '${config.networking.hostName}'"
      '';
    };

    programs.fzf.enable = true;

    programs.vim = {
      enable = true;
      extraConfig = ''
        source ${envconf}/.vimrc
      '';
    };

    programs.git = {
      enable = true;
      userName = "Joshua Gardner";
      userEmail = "joshgardner2000@gmail.com";
      extraConfig = {
        include = {
          path = "${envconf}/.gitconfig_colours";
        };
        credential = {
          helper = "manager";
          "https://github.com".username = "jgardn3r";
          credentialStore = "cache";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alejandra # to format nix files
    libnotify # to send system notifications
    git-credential-manager
  ];

  services.kanata = {
    enable = true;
    keyboards.main = {
      configFile = "${envconf}/jag_kanata.kbd";
    };
  };
}
