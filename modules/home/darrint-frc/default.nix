{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.frc;
in
{
  options.darrint.frc = {
    enable = lib.mkEnableOption "FRC robotics tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      advantagescope
      choreo
      elastic-dashboard
      pathplanner
      wpilib.glass
      wpilib.sysid
      wpilib.datalogtool
      wpilib.shuffleboard
      wpilib.smartdashboard
      wpilib.outlineviewer
      wpilib.pathweaver
      wpilib.robotbuilder
      wpilib.roborioteamnumbersetter
      wpilib.wpical
      wpilib.wpilib-utility
    ];

    programs.vscode.extensions = [
      pkgs.vscode-extensions.wpilibsuite.vscode-wpilib
    ];
  };
}
