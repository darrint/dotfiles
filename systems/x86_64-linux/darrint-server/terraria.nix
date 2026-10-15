{pkgs, ...}: {
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
      ProtectSystem = "strict";
      ReadWritePaths = "/var/lib/terraria";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
    };
  };

  networking.firewall.allowedTCPPorts = [7777];
  networking.firewall.allowedUDPPorts = [7777];
}
