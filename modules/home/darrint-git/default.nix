{
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.git;
in
{
  options.darrint.git = {
    enable = lib.mkEnableOption "Enable git and companions";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "darrint";
      userEmail = "darrint@fastmail.com";
    };
    programs.lazygit.enable = true;
    programs.gh = {
      enable = true;
      settings = {
        version = 1;
        git_protocol = "https";
        prompt = "enabled";
        prefer_editor_prompt = "disabled";
        color_labels = "disabled";
        accessible_colors = "disabled";
        accessible_prompter = "disabled";
        spinner = "enabled";
        aliases = {
          co = "pr checkout";
        };
      };
    };
  };
}
