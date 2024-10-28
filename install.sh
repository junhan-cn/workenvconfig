#!/bin/bash
yum install -y ripgrep bear tmux clang git

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
	echo "alias tmux='tmux -2'" >> ~/.bashrc  #解决tmux 和 vim 颜色不一致
	# 登录服务器自动进入tmux
	echo -e "if [ -z "\$TMUX" ]; then\n\ttmux attach-session || tmux new-session -n $HOSTNAME\nfi" >> ~/.bashrc
	source ~/.bashrc

}

function install_git() {
	cp -r workenvconfig/gitconfig ~/.gitconfig
}

install_nvim
install_tmux
install_git




