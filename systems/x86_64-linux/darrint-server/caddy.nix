{
  networking.firewall.allowedTCPPorts = [80 443];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "vw.thompsons.space".extraConfig = ''
        reverse_proxy http://localhost:8222
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
