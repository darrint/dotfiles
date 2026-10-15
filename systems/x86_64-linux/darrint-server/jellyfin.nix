{pkgs, ...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp -s 192.168.2.0/24 -m multiport --dports 8096,8920 -j nixos-fw-accept
    iptables -A nixos-fw -p udp -s 192.168.2.0/24 -m multiport --dports 1900,7359 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp -s 192.168.2.0/24 -m multiport --dports 8096,8920 -j nixos-fw-accept || true
    iptables -D nixos-fw -p udp -s 192.168.2.0/24 -m multiport --dports 1900,7359 -j nixos-fw-accept || true
  '';

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
