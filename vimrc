set t_Co=256  "256 colors

let g:Powerline_symbols = 'fancy' " Fancy powerline symbols

" set <Leader>
"let mapleader = "\\"
"
set nocompatible    " Disable vi-compatibility
set modeline        " File specific settings
set laststatus=2    " Always show the statusline
set encoding=utf-8  " Necessary to show Unicode glyphs

set backup                   " Automatic backups
set backupdir=~/.vim/backups " Where to save the automatic backups

" old versions cause sadness
if version >= 702
	call pathogen#infect()   " load plugins
	call pathogen#helptags() " load plugin help
endif

" slightly old versions cause slight saddness
if version >= 703
	set undofile            " Enable persistent undo history
	set undodir=~/.vim/undo " Directory to save undo history in
	set undolevels=1000     " Max number of undos that can be done
	set undoreload=10000    " Max number of lines to save for undo on buffer reload
endif

let g:snips_author = 'Josh Matthews'  " Name used by some snippets

filetype plugin indent on        " needed by some plugins and features
set ofu=syntaxcomplete#Complete  " enable omnicomplete
set nocompatible                 " use all the cool new features

set number                " Show Line Numbers
set shortmess=filnxtToOI  " Default shortmess += I. Removes vim intro message.
set backspace=2           " allows backspacing over eol, autoindents, and start of insert
set ts=4                  " number of spaces a tab is represented by
set noexpandtab           " do not replace tab characters with spaces
set shiftwidth=4          "number of spaces used to represent autoindents

syn on "syntax highlighting on

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

" Bring up NERDtree
map  <Leader>n :NERDTreeToggle<CR>

" Hex mode
map <Leader>hon :%!xxd<CR>
map <Leader>hof :%!xxd -r<CR>

"???
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal! g'\"" | endif 
"endif

set hlsearch      " highlight searches
set showcmd       " Show (partial) command in status line. 
set showmatch     " Show matching brackets.
set ignorecase    " Do case insensitive matching
set smartcase     " Do smart case matching
set incsearch     " Incremental search
set autowrite     " Automatically save before commands like :next and :make
set hidden        " Hide buffellumrs when they are abandoned
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
