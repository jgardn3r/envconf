{
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
  };
  envconf = builtins.toString ./..;
in {
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.jgardner = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        vscodevim.vim
      ];
      userSettings = {
        "vim.vimrc.enable" = true;
        "vim.vimrc.path" = envconf + "/.vimrc_vscode";
      };
    };
  };
}
