#!/usr/bin/env sh

if [ -e /bin/env]
then
	echo "... /bin/env found."
else
	sudo ln -s /usr/bin/env /bin/env
fi

### ATUALIZANDO SISTEMA E INSTALANDO LIBS BASICAS####

#Refresh no apt & dist-apt
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

#Instalação das libs necessárias
sudo apt-get install urxvt-unicode wget libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-composite0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev\
	libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf xutils-dev dh-autoreconf unzip git

#### ----------- FIM --------------- ####

### Instalando o xcb-util-xrm ###

git clone --recursive https://github.com/Airblader/xcb-util-xrm.git
cd xcb-util-xrm/
./autogen.sh
make
sudo make install
#Removendo pastas de instalacao do xcb
cd ..
rm -fr xcb-util-xrm

#O ldconfig é o responsável pela construção de um cache das libs no sistema.
#ao atualizar uma lib so SO, basta usar o ldconfig para reconstruir o cache ao invés
#de reiniciar todo o sistema.
#As configurações do ldconfig estão no arquivo /etc/ld.so.conf, nele voce coloca quais os diretórios onde o script deve pesquisar por bibliotecas para construir o cache.
#o parametro -p na segunda chamada é usado apenas para imprimir todas as libs no cache

### FIM XCB-UTIL-XRM ###

sudo ldconfig
sudo ldconfig -p

### Instalando i3-gaps ###

git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
autoreconf --force --install
rm -Rf build/
mkdir build
cd build/
 ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
 make
 sudo make install

# which i3
# ls -l /usr/bin/i3
cd ../..
rm -rf i3-gaps

### FIM ###

#Instalando anaconda (Python env)

mkdir anaconda_install
cd anaconda_install/
wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
sudo sh http://Anaconda3-2019.07-Linux-x86_64.sh

#Instalando libs secundarias: compiladores (gcc make), config de pacotes, pacotes python, etc.

sudo apt install git nitrogen rofi binutils wget gcc make pkg-config compton fakeroot cmake python-xcbgen xcb-proto libxcb-ewmh-dev wireless-tools libiw-dev libasound2-dev libpulse-dev libcurl4-openssl-dev libmpdclient-dev -y

### Instalando fontes adobe pro (terminal bonito) ###

git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git ~/.fonts/adobe-fonts/source-code-pro
fc-cache -f -v ~/.fonts/adobe-fonts/source-code-pro

### Instalando outras fontes ###
[ -d /usr/share/fonts/opentype ] || sudo mkdir /usr/share/fonts/opentype 
mkdir fonts 
cd fonts 
wget https://use.fontawesome.com/releases/v5.0.13/fontawesome-free-5.0.13.zip 
unzip fontawesome-free-5.0.13.zip 
cd fontawesome-free-5.0.13 
sudo cp use-on-desktop/* /usr/share/fonts 
sudo fc-cache -f -v 
rm -fr fonts

### baixando e compilando polybar ###
git clone https://github.com/jaagr/polybar
cd polybar
USE_GCC=ON ENABLE_I3=ON ENABLE_ALSA=ON ENABLE_PULSEAUDIO=ON ENABLE_NETWORK=ON ENABLE_MPD=ON ENABLE_CURL=ON ENABLE_IPC_MSG=ON INSTALL=OFF INSTALL_CONF=OFF ./build.sh -f
cd build
sudo make install
make userconfig
cd ../..
rm -rf polybar

### CRIANDO OS ARQUIVOS  ###

#XRESOURCES

if [ -e $HOME/.Xresources ]
then
	echo "... .Xresources found."
else]
	touch $HOME/.Xresources
fi

if [ -e $HOME/.extend.Xresources ]
then
	echo "... .extend.Xresources found."
else
	touch $HOME/.extend.Xresources
fi

#Background
if [ -e $HOME/.config/nitrogen/bg-saved.cfg ]
then
	echo "... .bg-saved.cfg found."
else
        mkdir $HOME/.config/nitrogen
        touch $HOME/.config/nitrogen/bg-saved.cfg
fi

#Polybar config
if [ -e $HOME/.config/polybar/config ]
then
	echo "... polybar/config found."
else
        mkdir $HOME/.config/polybar
        touch $HOME/.config/polybar/config
fi

#i3 config
if [ -e $HOME/.config/i3/config ]
then
	echo "... i3/config found."
else
        mkdir $HOME/.config/i3
        touch $HOME/.config/i3/config
fi

#Compton conf
if [ -e $HOME/.config/compton.conf ]
then
	echo "... compton.conf found."
else
	touch $HOME/.config/compton.conf
fi

#Escrevendo arquivos de configuração
actual_path=$(pwd)

#Escrevendo compton.conf
cat $actual_path/compton/compton.conf > $HOME/.config/compton.conf

#Escrevendo xresources
cat $actual_path/xresources/extend.Xresources > $HOME/.extend.Xresources
cat $actual_path/xresources/Xresources > $HOME/.Xresources

#Escrevendo i3 config
cat $actual_path/i3/config > $HOME/.config/i3/config

#Escrevendo polybar config
cat $actual_path/polybar/config > $HOME/.config/polybar/config

#Copiando coleção de wallpapers
cp -r $actual_path/Wallpapers $HOME/

#Setando o wallpaper principal
cat $actual_path/nitrogen/bg-saved.cfg > $HOME/.config/nitrogen/bg-saved.cfg

## Finalizando.. Instalando pacotes ##
sudo apt-get install google-chrome ranger -y

reboot
