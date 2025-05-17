{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    dbBackend = "sqlite";
    config = {
      DOMAIN = "https://ancientdad1974.duckdns.org";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = 8222;
    };
  };
}
