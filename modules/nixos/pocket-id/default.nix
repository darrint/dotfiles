{
  config,
  lib,
  ...
}: {
  options.darrint.pocket-id = {
    enable = lib.mkEnableOption "Pocket ID identity provider";
  };

  config = lib.mkIf config.darrint.pocket-id.enable {
    sops.secrets.pocket_id_encryption_key = {
      sopsFile = ../../../secrets/pocket-id.yaml;
      format = "yaml";
      mode = "600";
    };

    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = "https://id.thompsons.space";
        TRUST_PROXY = true;
        HOST = "127.0.0.1";
        PORT = 1411;
        ANALYTICS_DISABLED = true;
        VERSION_CHECK_DISABLED = true;
      };
      credentials = {
        ENCRYPTION_KEY = config.sops.secrets.pocket_id_encryption_key.path;
      };
    };
  };
}
