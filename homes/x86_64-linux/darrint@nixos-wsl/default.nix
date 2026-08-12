{
  darrint.neovim.enable = true;
  darrint.onedrive = {
    enable = true;
    settings = {
      # Must be a real Linux path — not the Windows OneDrive mount/symlink.
      sync_dir = "~/onedrive/de";
      check_nomount = "true";
      check_nosync = "true";
    };
  };
}
