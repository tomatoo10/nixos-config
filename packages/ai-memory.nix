{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "ai-memory";
  version = "1.17.1";

  src = pkgs.fetchFromGitHub {
    owner = "akitaonrails";
    repo = "ai-memory";
    rev = "2a85950ce8fa5c309fdc3adc481e98a02d824a9f";
    hash = "sha256-GTvYd66W4QVe0XvCH0u1wk725dR12V/qa2Dnvo/X9rY=";
  };

  cargoHash = "sha256-W6mPmsd1utxU8ip9vskM6iydOwC3O+5HRmlgik2s1ec=";

  doCheck = false;

  meta = with pkgs.lib; {
    description = "CLI for AI memory management";
    homepage = "https://github.com/akitaonrails/ai-memory";
    license = licenses.mit;
    mainProgram = "ai-memory";
    platforms = platforms.unix;
  };
}
