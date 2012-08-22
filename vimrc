"256 colors
set t_Co=256

" set <Leader>
"let mapleader=","

" Plugins
call pathogen#infect()

" Name used by some snippets
let g:snips_author = 'Josh Matthews'

" Enable omnicomplete
filetype plugin indent on
set ofu=syntaxcomplete#Complete

"Show Line Numbers
set number

"Default shortmess += I. Removes vim intro message.
set shortmess=filnxtToOI

"allows backspacing over eol, autoindents, and start of insert
set backspace=2

"number of spaces a tab is represented by
set ts=4

"do not replace tab characters with spaces
set noexpandtab

"number of spaces used to represent autoindents
set shiftwidth=4

"syntax highlighting on
syn on

" use python/perl regexp syntax
" nnoremap / /\v
" vnoremap / /\v

" Quick esc
inoremap kj <Esc>
set timeoutlen=500

" Easier navigation on wrapped lines
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

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
set autowrite    " Automatically save before commands like :next and :make
set hidden       " Hide buffellumrs when they are abandoned
set autoindent	  " Auto indent when starting a new line
set nosmartindent " Don't indent based on syntax
set wrap lbr      " Wrap by word

silent! autocmd InsertEnter * set nohlsearch
silent! autocmd InsertLeave * set hlsearch

" Different colorscheme if in diff mode
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
"highlight String ctermbg=none
"highlight LineNr ctermbg=none
