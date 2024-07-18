{ pkgs, ... }:

{
#  imports = [
#    inputs.nixvim.homeManagerModules.nixvim
#  ];

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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.killall
    pkgs._1password
    pkgs._1password-gui
    pkgs.direnv
    pkgs.waybar
    pkgs.fuzzel
    pkgs.vscode
    pkgs.zoom-us
    pkgs.slack
    pkgs.gimp
    pkgs.easyeffects
    pkgs.nixfmt-rfc-style
    pkgs.reaper
    pkgs.musescore
    pkgs.frotz
    pkgs.wl-clipboard
    pkgs.zk
    pkgs.nb
    pkgs.fzf
    pkgs.ripgrep
    pkgs.foot
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.nushell.enable = true;
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
    plugins = [
      pkgs.vimPlugins.which-key-nvim
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.tree-sitter-nix
        p.tree-sitter-vim
        p.tree-sitter-bash
        p.tree-sitter-lua
        p.tree-sitter-python
        p.tree-sitter-json
        p.tree-sitter-vimdoc
        p.tree-sitter-elixir
      ]))
      pkgs.vimPlugins.lsp-zero-nvim
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.autoclose-nvim
      pkgs.vimPlugins.lualine-nvim
      pkgs.vimPlugins.adwaita-nvim
      pkgs.vimPlugins.vim-better-whitespace
      pkgs.vimPlugins.better-escape-nvim
    ];
    extraLuaConfig =  builtins.readFile ./darrint-nvim-init.lua;
    extraPackages = [
      pkgs.pylyzer
      pkgs.nixd
      pkgs.elixir-ls
      pkgs.lexical
      pkgs.gopls
      pkgs.bash-language-server
    ];
  };
#  programs.nixvim = {
#    enable = true;
#    vimAlias = true;
#    viAlias = true;
#    defaultEditor = true;
#  };
  programs.git = {
    enable = true;
    userName = "darrint";
    userEmail = "darrint@fastmail.com";
  };
  programs.kitty.enable = true;
  # programs._1password.enable = true;
  # programs._1password-gui = {
  #   enable = true;
  #   polkitPolicyOwners = [ "darrint" ];
  # };
  programs.firefox.enable = true;
  programs.direnv.enable = true;
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-gradient-source
    ];
  };
}
