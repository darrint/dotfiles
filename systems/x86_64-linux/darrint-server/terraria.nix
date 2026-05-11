{pkgs, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "dotnet-runtime-6.0.36"
  ];
  users.users.terraria = {
    isSystemUser = true;
    group = "terraria";
    home = "/var/lib/terraria";
    createHome = true;
  };
  users.groups.terraria = {};

  systemd.services.terraria = {
    description = "TShock Terraria Server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "terraria";
      WorkingDirectory = "/var/lib/terraria";
      ExecStart = "${pkgs.tshock}/bin/TShock.Server -world /var/lib/terraria/World.wld -autocreate 2 -port 7777 -maxplayers 16";
      Restart = "on-failure";
    };
  };

  networking.firewall.allowedTCPPorts = [7777];
  networking.firewall.allowedUDPPorts = [7777];
}
