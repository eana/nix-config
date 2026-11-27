{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "aws-export-profile";
  version = "unstable-2023-01-20";
  src = fetchFromGitHub {
    owner = "cytopia";
    repo = "aws-export-profile";
    rev = "a08ed774a36e5a7386adf645652a4af7b972e208"; # specific commit/tag
    sha256 = "sha256-hvQzKXHfeyN4qm6kEAG/xuIqmHhL8GKpvn8aE+gTMDE=";
  };
  installPhase = ''
    mkdir -p $out/bin
    cp aws-export-profile $out/bin/aws-export-profile.sh
    chmod +x $out/bin/aws-export-profile.sh
  '';
}
