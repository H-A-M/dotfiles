filetype plugin indent on
syntax on

set nocompatible
set encoding=utf8

colorscheme ron
set background=dark

set nobackup
set nowritebackup
set noswapfile

set vb t_vb=
set noshowmode
set noshowmatch

set number
set ruler

set showcmd
set wildmenu
set wildmode=longest,list:longest,list:full

set tabstop=4
set shiftwidth=4
set expandtab

set incsearch
set hlsearch
" Set Alt-U to toggle search highlighting like less
map <silent> u :set hlsearch!<cr>

" Use arrow keys to scroll
noremap <UP> <C-Y>
noremap <DOWN> <C-E>

" Unbind these
noremap <LEFT> <NOP>
noremap <RIGHT> <NOP>

