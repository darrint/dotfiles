{
  lib,
  config,
  ...
}: let
  cfg = config.darrint.netbird.useRoutingFeatures;
in {
  options.darrint.netbird.useRoutingFeatures = lib.mkOption {
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

  config = {
    services.netbird = {
      enable = true;
      clients.default.config = {
        ServerSSHAllowed = true;
      };

      useRoutingFeatures = cfg;
    };
  };
}
