"256 colors
set t_Co=256

" set <Leader>
let mapleader=","

"filetype on
"filetype plugin on
"filetype indent on

"Show Line Numbers
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

"syntax highlighting on
syn on

" use python/perl regexp syntax
" nnoremap / /\v
" vnoremap / /\v

" Quick esc
inoremap jf <Esc>
set timeoutlen=500

" Hex mode
map <Leader>hon :%!xxd<CR>
map <Leader>hof :%!xxd -r<CR>

"???
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal! g'\"" | endif 
"endif

"set nohlsearch	"don't highlight searches
set showcmd      " Show (partial) command in status line. 
set showmatch    " Show matching brackets.
set ignorecase   " Do case insensitive matching
set smartcase    " Do smart case matching
set incsearch    " Incremental search
"set autowrite    " Automatically save before commands like :next and :make
set hidden       " Hide buffellumrs when they are abandoned
set autoindent	  " Auto indent when starting a new line
set smartindent  " Indent based on syntax

"if &diff
"	colorscheme desert
"else
"	colorscheme darkblue
"endif"

" Set Colorscheme
let g:inkpot_black_background = 1
colorscheme inkpot

" Gain root privs if needed to write
command W w !sudo tee % > /dev/null

" Setup cursor crosshairs 
set cursorline
set cursorcolumn
highlight CursorLine ctermbg=20 cterm=bold term=bold
highlight CursorColumn ctermbg=20
"" Fix backgrounds for transparent terminals
"highlight Normal ctermbg=none
highlight String ctermbg=none
highlight LineNr ctermbg=none
