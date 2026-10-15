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
      inputs.numtide-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      inputs.numtide-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      pkgs.playwright-mcp
      pkgs.mcp-nixos
    ];
  };
}
