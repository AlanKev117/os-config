cp .enough $HOME/.enough
cp .inputrc $HOME/.inputrc
rsync -av --delete .config/enough/ $HOME/.config/enough/