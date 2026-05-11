# modules/nixos/sops.nix
{
  config,
  lib,
  ...
}: {
  options.darrint.sops = {
    enable = lib.mkEnableOption "SOPS secret management";
  };

  config = lib.mkIf config.darrint.sops.enable {
    # Core SOPS settings
    sops.defaultSopsFile = ../../../secrets/netbird.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.age.keyFile = "/var/lib/sops-nix/age/keys.txt";

    # Your NetBird secrets
    sops.secrets = {
      netbird_auth_secret = {mode = "600";};
      netbird_encryption_key = {mode = "600";};
    };

    # Directory for age key
    systemd.tmpfiles.rules = [
      "d /var/lib/sops-nix/age 0755 root root"
    ];
  };
}
