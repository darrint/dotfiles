{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.darrint.netbird.useRoutingFeatures;
  netbird-up = pkgs.writeShellApplication {
    name = "netbird-up";
    runtimeInputs = [pkgs.netbird];
    text = builtins.readFile ./netbird-up;
  };
in {
  options.darrint.netbird = {
    useRoutingFeatures = lib.mkOption {
      type = lib.types.enum [
        "none"
        "client"
        "server"
        "both"
      ];
      default = "none";
      example = "server";
      description = ''
        Copied from services.netbird.useRoutingFeatures option.
        Enables settings required for NetBird's routing features: Network Resources, Network Routes & Exit Nodes.

        When set to `client` or `both`, reverse path filtering will be set to loose instead of strict.
        When set to `server` or `both`, IP forwarding will be enabled.
      '';
    };

    useUserSpaceWireguard = lib.mkEnableOption "disable kernel WireGuard and force userspace via NB_WG_KERNEL_DISABLED (required for WSL2)";
  };

  config = {
    environment.systemPackages = [netbird-up];

    # Work around a current bug.
    # https://github.com/NixOS/nixpkgs/issues/505846
    systemd.services.${config.services.netbird.clients.default.service.name} = {
      path = [pkgs.shadow];
      environment = lib.mkIf config.darrint.netbird.useUserSpaceWireguard {
        NB_WG_KERNEL_DISABLED = "true";
      };
    };

    services.netbird = {
      enable = true;
      # leave this out while we're pulling from unstable as it won't build
      ui.enable = false;
      clients.default.config = {
        ServerSSHAllowed = true;
      };

      useRoutingFeatures = cfg;
    };
  };
}
