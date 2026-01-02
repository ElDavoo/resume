{
  description = "Compile CV in PDF";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.11;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      # TODO replace scheme-full with scheme-minimal
      tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latex-bin latexmk
          extsizes pdfx everyshi xcolor luatex85 xmpincl accsupp fontawesome5
          luatexbase koma-script fontspec
          ;
      };
    in rec {
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "latex-demo-document";
          src = self;
          buildInputs = [ pkgs.coreutils pkgs.ncurses tex ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            
            # Build English version
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var TEXMFCACHE=.cache/.texmf-cache \
            latexmk -interaction=nonstopmode \
            -shell-escape \
            -pdf \
            -lualatex \
            -jobname=resume-en \
            -usepretex='\RequirePackage{luatex85,shellesc}' \
            resume.tex
            
            # Build Italian version
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var TEXMFCACHE=.cache/.texmf-cache \
            latexmk -interaction=nonstopmode \
            -shell-escape \
            -pdf \
            -lualatex \
            -jobname=resume-it \
            -usepretex='\RequirePackage{luatex85,shellesc}' \
            resume.tex
            
            # Build French version
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var TEXMFCACHE=.cache/.texmf-cache \
            latexmk -interaction=nonstopmode \
            -shell-escape \
            -pdf \
            -lualatex \
            -jobname=resume-fr \
            -usepretex='\RequirePackage{luatex85,shellesc}' \
            resume.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp resume-en.pdf resume-it.pdf resume-fr.pdf $out/
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
