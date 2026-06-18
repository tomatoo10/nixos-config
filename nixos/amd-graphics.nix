{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
      # Support VA-API pour AMD
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };
  hardware.amdgpu.opencl.enable = true;
  environment.variables.AMD_VULKAN_ICD = "RADV";

  environment.systemPackages = with pkgs; [
    clinfo
    rocmPackages.rocminfo
  ];
}
