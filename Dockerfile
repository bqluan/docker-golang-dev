FROM golang:1.8

# Set timezone to Asia/Shanghai
RUN echo "Asia/Shanghai" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata

# Debian mirror in China
RUN { \
		echo "deb http://ftp.cn.debian.org/debian/ jessie main"; \
		echo "deb http://ftp.cn.debian.org/debian/ jessie-updates main"; \
	} > /etc/apt/sources.list

# Packaged dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	git \
	locales \
	unzip \
	vim

# Generate locale en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
	&& locale-gen
ENV LANG en_US.UTF-8

# Install pathogen.vim
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle \
	&& curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim \
	&& { \
		echo "execute pathogen#infect()"; \
		echo "syntax on"; \
		echo "filetype plugin indent on"; \
	} > ~/.vimrc

# Install vim-go
RUN git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go \
	&& export GOPATH="$(mktemp -d)" \
	&& GOBIN=/usr/local/bin vim "+set nomore" +GoInstallBinaries +qall \
	&& rm -rf "$GOPATH"

# Install govendor
RUN export GOPATH="$(mktemp -d)" \
	&& GOBIN=/usr/local/bin go get github.com/kardianos/govendor \
	&& rm -rf "$GOPATH"
