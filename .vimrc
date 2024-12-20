filetype plugin on
filetype indent on

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Highlight trailing whitespace in all files
autocmd BufRead,BufNewFile * match Error /\s\+$/

set autoindent

syntax on

" Set backspace so it acts more intuitively
set backspace=indent,eol,start
