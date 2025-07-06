#!/bin/bash

set -e

brew install --cask xquartz
brew install ghcup

ghcup install ghc
ghcup install stack
ghcup set ghc default
ghcup set stack default

mkdir -p ~/.xmonad
cd ~/.xmonad

git clone https://github.com/xmonad/xmonad
git clone https://github.com/xmonad/xmonad-contrib

cat <<EOF > stack.yaml
resolver: lts-21.25
packages:
- ./xmonad
- ./xmonad-contrib
EOF

git clone https://github.com/arnihermann/osxmonad.git
cd xmonad
git apply ../osxmonad/xmonad.patch
cd ..

stack setup
stack install

cat <<EOF > ~/.xmonad/xmonad.hs
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Util.EZConfig

main = xmonad =<< xmobar def
  { modMask = mod1Mask
  } \`additionalKeysP\`
  [ ("M-S-q", io exitSuccess)
  , ("M-<Return>", spawn "xterm")
  ]
EOF

mkdir -p ~/.config/xmobar
cat <<EOF > ~/.config/xmobar/xmobar.config
Config { font = "xft:Monaco-12"
       , bgColor = "#1c1c1c"
       , fgColor = "#dcdccc"
       , position = Top
       , commands = [ Run Date "%a %b %_d %H:%M" "date" 10 ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%date% }{"
       }
EOF

cat <<EOF > ~/.xinitrc
xrdb -merge ~/.Xresources
exec ~/.local/bin/xmonad
EOF

cat <<EOF > ~/.Xresources
XTerm*faceName: Monaco
XTerm*faceSize: 12
XTerm*loginShell: true
EOF
