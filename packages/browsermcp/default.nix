{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "browsermcp";
  version = "0.1.3";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@browsermcp/mcp/-/mcp-${version}.tgz";
    hash = "sha256-KtNMKRRcqAxfLn2OyQ4FiWl7GTOLK0WoPJGNSQekz5Y=";
  };

  # npm pack tarballs unpack into a "package" directory
  sourceRoot = "package";

  # Upstream tarball has workspace:* devDependencies that break npm install.
  # Use our cleaned package.json + lockfile (production deps only).
  postPatch = ''
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-22U5mxe5suCxpak/WUxB6ruDgUeZs3ahDgxKqhJxkl4=";

  dontNpmBuild = true;

  meta = {
    description = "MCP server for browser automation using Browser MCP";
    homepage = "https://browsermcp.io";
    license = lib.licenses.asl20;
    mainProgram = "mcp-server-browsermcp";
    platforms = lib.platforms.linux;
  };
}
