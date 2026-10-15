{ pkgs, lib, ... }:
{
  home = {
    packages = [ pkgs.duti ];

    # Default apps bound by UTI, not extension, so casing (.jpg/.JPG) never diverges.
    file.".duti.conf".text = ''
      # XnViewMP image viewers
      com.xnview.XnView public.jpeg all
      com.xnview.XnView public.png all
      com.xnview.XnView public.tiff all
      com.xnview.XnView com.compuserve.gif all
      com.xnview.XnView com.microsoft.bmp all
      com.xnview.XnView public.heic all
      com.xnview.XnView public.webp all
      com.xnview.XnView public.avif all
      com.xnview.XnView public.jpeg-2000 all
      com.xnview.XnView com.truevision.tga-image all
    '';

    activation.setFileAssociations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Setting file associations with duti..."
      ${pkgs.duti}/bin/duti "$HOME/.duti.conf"
    '';
  };
}
