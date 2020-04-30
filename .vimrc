" Create comment using this ->  "

" Allow mouse cursor to select text
set mouse=v
filetype indent on
syntax on
" Enable better paste formatting
"set paste

" Fix indentation
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
" add yaml stuffs
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" bin paste toggle to F2
set pastetoggle=<F2>
set rnu
