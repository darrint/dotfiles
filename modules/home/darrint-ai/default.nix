{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  options.darrint.ai = {
    enable = lib.mkEnableOption "AI coding and MCP tools";
  };

  config = lib.mkIf config.darrint.ai.enable {
    home.packages = [
      inputs.numtide-ai-tools.packages.${pkgs.system}.opencode
      pkgs.playwright-mcp
      pkgs.mcp-nixos
    ];
  };
}
