#!/bin/bash
yum install -y ripgrep bear tmux clang

# build kernel
yum install -y make gcc flex bison elfutils-devel openssl-devel 

function install_vim() {

	wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz 

	rm -rf /opt/nvim*
	tar -C /opt -xzf nvim-linux64.tar.gz

	rm -rf nvim-linux64.tar.gz 
	sed -i '/nvim-linux64/d' ~/.bashrc 
	echo "export PATH="$PATH:/opt/nvim-linux64/bin"" >> ~/.bashrc 
	source ~/.bashrc

	mkdir  ~/.config
	cp -r  workenvconfig/nvim ~/.config
	rm -rf workenvconfig
}

function install_tmux() {
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 
	cp -r workenvconfig/tmux-hanzj/tmux.conf  ~/.tmux.conf
}


install_nvim
install_tmux




