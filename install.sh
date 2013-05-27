#!/bin/bash

mkdir Dependencies
cd Dependencies

#linux-lowtency kernel installation
apt-get install linux-lowlatency

#installing JACK
apt-get install jackd qjackctl libjack-dev

#installing jacktrip
apt-get install jacktrip

#installing jmess
apt-get install libasound2-dev g++ qt4-dev-tools
wget http://jmess-jack.googlecode.com/files/jmess-1.0.1.tar.gz
tar xvf jmess-1.0.1.tar.gz
cd jmess-1.0.1/src
./build
make install
cd ../..

#installing SuperCollider
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FABAEF95
add-apt-repository ppa:supercollider/ppa
apt-get update
apt-get install supercollider supercollider-gedit supercollider-dev libsclang1 

#installing Java RunTime Environment
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java8-installer

#installing SwingOSC
wget http://iweb.dl.sourceforge.net/project/swingosc/swingosc/0.70/SwingOSC-0.70-Linux.zip
mkdir SwingOSC-0.70-Linux
unzip SwingOSC-0.70-Linux-zip -d SwingOSC-0.70-Linux
cd SwingOSC-0.70-Linux
sh install_linux_local.sh
cd ..

#installing OpenNI
apt-get install git freeglut3-dev libusb-1.0-0-dev doxygen graphviz
git clone https://github.com/OpenNI/OpenNI
cd OpenNI/Platform/Linux/CreateRedist
./RedistMaker
cd ../Redist/OpenNI-Bin-Dev*
./install.sh
cd ../../../../../..

#installing OSCeleton_for_NMP
cd OSCeleton_for_NMP
make

