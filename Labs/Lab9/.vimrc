"set nocompatible              " be iMproved, required
filetype plugin on
"filetype off                  " required
"syntax on
set number

"Changing Leader Key
"let mapleader = ","

" highlight current line
"set cursorline

" Allow us to use Ctrl-s and Ctrl-q as keybinds
silent !stty -ixon
" Restore default behaviour when leaving Vim.
autocmd VimLeave * silent !stty ixon

" Ctrl+S for save
nmap <c-s> :w<CR>
imap <c-s> <Esc>:w<CR>
" Ctrl-q for save and quit
nmap <c-q> :wqa<CR>
imap <c-q> <Esc>:wqa<CR>

" q -> quit
nmap q :qa<CR>
