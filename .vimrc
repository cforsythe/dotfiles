colorscheme badwolf  " https://github.com/sjl/badwolf.git clone repo then run mv badwolf/colors/*.vim ~/.vim/colors
syntax enable
let mapleader = ","
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set number
set cursorline
filetype indent on
set wildmenu
set lazyredraw
set showmatch
set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>
nnoremap j gj
nnoremap k gk

" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

let skip_defaults_vim=1
if has("syntax")
  syntax on
endif
autocmd FileType yaml,json setlocal ts=2 sts=2 sw=2 expandtab
