#!/bin/bash
yum install -y ripgrep bear tmux clang git

# build kernel
yum install -y make gcc flex bison elfutils-devel openssl-devel 

function install_vim() {
	wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz 

	rm -rf /opt/nvim-linux-*
	tar -C /opt -xzf nvim-linux-x86_64.tar.gz

	if [ $? -eq 1 ];then
		sed -i '/nvim-linux-x86_64/d' ~/.bashrc 
		echo "export PATH="$PATH:/opt/nvim-linux-x86_64/bin"" >> ~/.bashrc 
		source ~/.bashrc
	fi

	mkdir ~/.config
	cp -r  nvim ~/.config
	rm -rf nvim-linux-x86_64.tar.gz 
}

function install_tmux() {
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 
	cp -r workenvconfig/tmux-hanzj/tmux.conf  ~/.tmux.conf
	grep -q "tmux" ~/.bashrc
	if [ $? -eq 1 ] ;then
		echo "alias tmux='tmux -2'" >> ~/.bashrc  #解决tmux 和 vim 颜色不一致
		echo -e "if [ -z "\$TMUX" ]; then\n\ttmux attach-session || tmux new-session -n $HOSTNAME\nfi" >> ~/.bashrc
	fi 
	# 登录服务器自动进入tmux
	source ~/.bashrc

}

function install_git() {
	cp -r gitconfig ~/.gitconfig
}

install_nvim
install_tmux
#install_git




