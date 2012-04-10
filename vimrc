#call pathogen#infect()
set t_Co=256
filetype plugin indent on
set number
set shortmess=filnxtToOI
set backspace=2
set ts=3
set expandtab
set shiftwidth=3
syn on
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif 
endif

set nohlsearch
set showcmd      " Show (partial) command in status line. 
set showmatch    " Show matching brackets.
set ignorecase      " Do case insensitive matching
set smartcase    " Do smart case matching
set incsearch    " Incremental search
set autowrite    " Automatically save before commands like :next and :make
set hidden             " Hide buffellumrs when they are abandoned
set autoindent
colorscheme darkblue

" Setup cursor kholer 
set cursorline
set cursorcolumn
highlight CursorLine ctermbg=darkblue cterm=bold
highlight CursorColumn ctermbg=darkblue
highlight MatchParen ctermbg=white ctermfg=black
