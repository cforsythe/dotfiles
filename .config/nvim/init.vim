set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc


call plug#begin('~/.local/share/nvim/plugged')

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jiangmiao/auto-pairs'
Plug 'davidhalter/jedi-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'sbdchd/neoformat'
Plug 'morhetz/gruvbox'
Plug 'w0rp/ale'
Plug 'elzr/vim-json'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'


call plug#end()

" deoplete config

let g:deoplete#enable_at_startup = 1

" vim-airline config
let g:airline_theme='badwolf' " <theme> is a valid theme name


" jedi-vim config

" disable autocompletion, because we use deoplete for completion
let g:jedi#completions_enabled = 0

" open the go-to function in split, not another buffer
let g:jedi#use_splits_not_buffers = "right"


" neoformat config

" Enable alignment
let g:neoformat_basic_format_align = 1

" Enable tab to space conversion
let g:neoformat_basic_format_retab = 1

" Enable trimmming of trailing whitespace
let g:neoformat_basic_format_trim = 1

colorscheme gruvbox
set background=dark " use dark mode

let g:ale_completion_autoimport = 1
nnoremap gp :silent %!prettier --stdin-filepath %<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
autocmd BufWritePre,TextChanged,InsertLeave *.js Neoformat

let g:vim_json_indent = 2
let g:ale_echo_msg_format = '%linter% says %s'
lua require('config')
