{
  # Audio/firmware configuration
  # I spotted this in the logs:
  # Jan 15 16:48:17 nixbox kernel: snd_soc_avs 0000:00:1f.3: Direct firmware load for intel/avs/hda-10ec0298-tplg.bin failed with error -2
  # Jan 15 16:48:17 nixbox kernel: snd_soc_avs 0000:00:1f.3: request topology "intel/avs/hda-10ec0298-tplg.bin" failed: -2
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.0: trying to load fallback topology hda-generic-tplg.bin
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.0: ASoC: Parent card not yet available, widget card binding deferred
  # Jan 15 16:48:17 nixbox kernel: input: hdaudioB0D0 Headphone Mic as /devices/platform/avs_hdaudio.0/sound/card0/input21
  # Jan 15 16:48:17 nixbox kernel: snd_hda_codec_hdmi hdaudioB0D2: creating for HDMI 0 0
  # Jan 15 16:48:17 nixbox kernel: snd_hda_codec_hdmi hdaudioB0D2: skipping capture dai for HDMI 0
  # Jan 15 16:48:17 nixbox kernel: snd_hda_codec_hdmi hdaudioB0D2: creating for HDMI 1 1
  # Jan 15 16:48:17 nixbox kernel: snd_hda_codec_hdmi hdaudioB0D2: skipping capture dai for HDMI 1
  # Jan 15 16:48:17 nixbox kernel: snd_hda_codec_hdmi hdaudioB0D2: creating for HDMI 2 2
  # Jan 15 16:48:17 nixbox kernel: snd_hda_codec_hdmi hdaudioB0D2: skipping capture dai for HDMI 2
  # Jan 15 16:48:17 nixbox kernel: snd_soc_avs 0000:00:1f.3: Direct firmware load for intel/avs/hda-80862809-tplg.bin failed with error -2
  # Jan 15 16:48:17 nixbox kernel: snd_soc_avs 0000:00:1f.3: request topology "intel/avs/hda-80862809-tplg.bin" failed: -2
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.2: trying to load fallback topology hda-8086-generic-tplg.bin
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.2: ASoC: Parent card not yet available, widget card binding deferred
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.2: avs_card_late_probe: mapping HDMI converter 1 to PCM 1 (0000000044de3967)
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.2: avs_card_late_probe: mapping HDMI converter 2 to PCM 2 (000000007a87bd93)
  # Jan 15 16:48:17 nixbox kernel: avs_hdaudio avs_hdaudio.2: avs_card_late_probe: mapping HDMI converter 3 to PCM 3 (00000000c5ee6c25)
  # Jan 15 16:48:17 nixbox kernel: input: hdaudioB0D2 HDMI/DP,pcm=1 as /devices/platform/avs_hdaudio.2/sound/card1/input22
  # Jan 15 16:48:17 nixbox kernel: input: hdaudioB0D2 HDMI/DP,pcm=2 as /devices/platform/avs_hdaudio.2/sound/card1/input23
  # Jan 15 16:48:17 nixbox kernel: input: hdaudioB0D2 HDMI/DP,pcm=3 as /devices/platform/avs_hdaudio.2/sound/card1/input24
  # The sound refused to work until I blacklisted snd_soc_avs
  # https://discourse.nixos.org/t/no-microphone-how-to-get-firmware-dsp-basefw-bin/38198/9
  boot.blacklistedKernelModules = [ "snd_soc_avs" ];
  hardware.enableAllFirmware = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
