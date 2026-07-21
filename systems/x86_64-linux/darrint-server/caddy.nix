{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "vw.thompsons.space".extraConfig = ''
        reverse_proxy http://localhost:8222
      '';
      "au.thompsons.space".extraConfig = ''
        reverse_proxy http://localhost:9000
      '';
      "id.thompsons.space".extraConfig = ''
        reverse_proxy http://127.0.0.1:1411
      '';
      "frc.thompsons.space".extraConfig = ''
        reverse_proxy http://127.0.0.1:5173
      '';
      "thompsons.space".extraConfig = ''
        respond "go away"
      '';
      "ancientdad1974.duckdns.org".extraConfig = ''
        respond "go away"
      '';
    };
  };
}
