{ pkgs, lib, localPackages, ... }:

{
  imports = [ ./darrint-hyprland.nix ];

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

  fonts = {
    fontconfig = {
      defaultFonts = {
        monospace = ["Iosevka NFM Light"];
      };
    };
  };

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
    pkgs.libsForQt5.qt5.qtwayland
    pkgs.kdePackages.qtwayland
    pkgs.killall
    pkgs._1password
    pkgs._1password-gui
    pkgs.direnv
    # pkgs.waybar
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
    pkgs.fd
    pkgs.foot
    pkgs.libnotify
    pkgs.gnomeExtensions.blur-my-shell
    pkgs.gnomeExtensions.tiling-shell
    pkgs.devenv
    pkgs.htop
    pkgs.tuckr
    pkgs.kitty
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
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;
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
      pkgs.vimPlugins.nvim-cmp
      pkgs.vimPlugins.cmp-nvim-lsp
      pkgs.vimPlugins.cmp-buffer
      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.autoclose-nvim
      pkgs.vimPlugins.lualine-nvim
      pkgs.vimPlugins.adwaita-nvim
      pkgs.vimPlugins.vim-better-whitespace
      pkgs.vimPlugins.better-escape-nvim
      pkgs.vimPlugins.modus-themes-nvim
      pkgs.vimPlugins.gitgutter
    ];
    extraPackages = [
      pkgs.pylyzer
      pkgs.nixd
      pkgs.elixir-ls
      pkgs.lexical
      pkgs.gopls
      pkgs.bash-language-server
      pkgs.fd
      pkgs.ripgrep
      pkgs.lua-language-server
    ];
    extraLuaConfig = ''
      -- Add a directory to the package.path
      package.path = package.path .. ';~/.config/dotfiles2/nvim'

      -- Now you can require the file
      -- local my_config = require('nvim')

      dofile(vim.fn.stdpath("config") .. '/../dotfiles2/nvim/init.lua')
      '';
  };
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
  programs.firefox.enable = true;
  programs.brave.enable = true;
  programs.direnv.enable = true;
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-gradient-source
    ];
  };
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      sensible
    ];
  };
  programs.waybar = {
    enable = true;
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

  # systemd = {
  #   user.services.polkit-kde-authentication-agent-1 = {
  #     Unit.Description = "polkit-kde-authentication-agent-1";
  #     # wantedBy = [ "graphical-session.target" ];
  #     # wants = [ "graphical-session.target" ];
  #     # after = [ "graphical-session.target" ];
  #     Service = {
  #         Type = "simple";
  #         ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
  #         Restart = "on-failure";
  #         RestartSec = 1;
  #         TimeoutStopSec = 10;
  #       };
  #   };
  # };
}
