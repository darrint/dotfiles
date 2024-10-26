{ pkgs, lib, localPackages, ... }:

{
  imports = [
    ./neovim.nix
  ];

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "darrint";
  home.homeDirectory = "/home/darrint";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # stylix.targets.neovim.enable = false;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.killall
    pkgs._1password
    pkgs.direnv
    pkgs.nixfmt-rfc-style
    pkgs.frotz
    pkgs.zk
    pkgs.nb
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fd
    pkgs.devenv
    pkgs.htop
    pkgs.lolcat
    pkgs.figlet
    pkgs.zellij
    localPackages.darrint-dotfiles2
    localPackages.darrint-utils
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  # };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/darrint/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
  };

  # Let Home Manager install and manage itself.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.nushell.enable = true;
  # programs.neovim = {
  #   enable = true;
  #   vimAlias = true;
  #   viAlias = true;
  #   defaultEditor = true;
  #   plugins = [
  #     pkgs.vimPlugins.which-key-nvim
  #     (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
  #       p.tree-sitter-nix
  #       p.tree-sitter-vim
  #       p.tree-sitter-bash
  #       p.tree-sitter-lua
  #       p.tree-sitter-python
  #       p.tree-sitter-json
  #       p.tree-sitter-vimdoc
  #       p.tree-sitter-elixir
  #     ]))
  #     pkgs.vimPlugins.lsp-zero-nvim
  #     pkgs.vimPlugins.nvim-lspconfig
  #     pkgs.vimPlugins.nvim-cmp
  #     pkgs.vimPlugins.cmp-nvim-lsp
  #     pkgs.vimPlugins.cmp-buffer
  #     pkgs.vimPlugins.telescope-nvim
  #     pkgs.vimPlugins.autoclose-nvim
  #     pkgs.vimPlugins.lualine-nvim
  #     pkgs.vimPlugins.adwaita-nvim
  #     pkgs.vimPlugins.vim-better-whitespace
  #     pkgs.vimPlugins.better-escape-nvim
  #     pkgs.vimPlugins.modus-themes-nvim
  #     pkgs.vimPlugins.gitgutter
  #   ];
  #   extraPackages = [
  #     pkgs.pylyzer
  #     pkgs.nixd
  #     pkgs.elixir-ls
  #     pkgs.lexical
  #     pkgs.gopls
  #     pkgs.bash-language-server
  #     pkgs.fd
  #     pkgs.ripgrep
  #     pkgs.lua-language-server
  #   ];
  #   extraLuaConfig = ''
  #     -- Add a directory to the package.path
  #     package.path = package.path .. ';~/.config/dotfiles2/nvim'
  #
  #     -- Now you can require the file
  #     -- local my_config = require('nvim')
  #
  #     dofile(vim.fn.stdpath("config") .. '/../dotfiles2/nvim/init.lua')
  #     '';
  # };
  programs.git = {
    enable = true;
    userName = "darrint";
    userEmail = "darrint@fastmail.com";
  };
  # programs._1password.enable = true;
  # programs._1password-gui = {
  #   enable = true;
  #   polkitPolicyOwners = [ "darrint" ];
  # };
  programs.direnv.enable = true;
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      sensible
    ];
  };

  home.activation = {
    installdotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${localPackages.darrint-dotfiles2}/bin/installdotfiles
    '';
  };

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
}
