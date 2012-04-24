"256 colors
set t_Co=256

filetype plugin indent on

set number

"Default shortmess += I. Removes vim intro message.
set shortmess=filnxtToOI

"allows backspacing over eol, autoindents, and start of insert
set backspace=2

"number of spaces a tab is represented by
set ts=3

"do not replace tab characters with spaces
set noexpandtab

"number of spaces used to represent autoindents
set shiftwidth=3

"
syn on


"???
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal! g'\"" | endif 
"endif

set nohlsearch
set showcmd      " Show (partial) command in status line. 
set showmatch    " Show matching brackets.
set ignorecase   " Do case insensitive matching
set smartcase    " Do smart case matching
set incsearch    " Incremental search
"set autowrite    " Automatically save before commands like :next and :make
set hidden       " Hide buffellumrs when they are abandoned
set autoindent	  " Auto indent when starting a new line
set smartindent  " Indent based on syntax
colorscheme darkblue

" Setup cursor crosshairs 
set cursorline
set cursorcolumn
highlight CursorLine ctermbg=darkblue cterm=bold term=bold
highlight CursorColumn ctermbg=darkblue
