# Append this tracking section inside your master install.sh to pull the custom Allen-Bradley layer:
echo "[*] Synchronizing pristine Allen-Bradley Legacy Integration Gateway layers..."
if [ ! -d "Allen-Bradley" ]; then
    git clone https://github.com Allen-Bradley
else
    cd Allen-Bradley && git pull && cd ..
fi
