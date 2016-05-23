"-------------------------------------------------------------------------------
" Important {1
"-------------------------------------------------------------------------------
set nocompatible             " Disable vi-compatibility
filetype plugin indent on    " Awesome filetype detection

" Fish shell causes problems
if &shell =~# 'fish$'
    set shell=/bin/zsh
endif

" Remember global variables with ALL CAPS names
if !empty(&viminfo)
    set viminfo^=!
endif

" Use space as leader
let mapleader = "\<Space>"
nnoremap <Space> <Nop>


"-------------------------------------------------------------------------------
" Source plugin config if it exists {1
"-------------------------------------------------------------------------------
let s:plugin_file = expand('~/.vim/vimrc_plugins')
if filereadable(s:plugin_file) && &loadplugins
    exec 'source ' . s:plugin_file
endif


"-------------------------------------------------------------------------------
" Movement {1
"-------------------------------------------------------------------------------
" Make colemak a bit easier
set langmap=hk,jh,kj
set langnoremap

" Mouse support in normal mode
set mouse=n

" Quick escape
inoremap tn <Esc>

" Easier navigation on wrapped lines
" nnoremap j gj
" nnoremap k gk
" vnoremap j gj
" vnoremap k gk

" Time in milliseconds to wait for next key press
set timeout
set timeoutlen=250
set ttimeout
set ttimeoutlen=50

" Load matchit.vim, but only if we haven't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
    runtime! macros/matchit.vim
endif


"-------------------------------------------------------------------------------
" Display and messages {1
"-------------------------------------------------------------------------------
syn on                    " Use syntax highlighting
set number                " Show line numbers
set relativenumber        " Show relative line numbers
set wrap                  " Wrap lines
set linebreak             " Break on words
set breakindent           " Indent wrapped lines
set showmatch             " Show matching brackets
set showcmd               " Show (partial) command in status line
set ttyfast               " Faster updates
set hidden                " Hide buffellumrs when they are abandoned
set laststatus=2          " Always show the statusline
set ruler                 " Show line and column number
set wildmenu              " Show a menu for completing commands
set scrolloff=3           " Show 5 lines of context
set sidescrolloff=5       " Show 5 lines of horizontal context
set tabpagemax=50         " Max number of tabs to be opened with -p or :tab all
set shortmess=filnxtToOI  " Default shortmess += I. Removes vim intro message
set display+=lastline     " Show as much of the last line as possible

" Set extra listchars, and use unicode glyphs if available
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
if !has('win32') && (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8')
    let &listchars = "tab:\u21e5 ,trail:\u2423,extends:\u21c9,precedes:\u21c7,
                \nbsp:\u00b7"
endif


"-------------------------------------------------------------------------------
" Tabs and Indent {1
"-------------------------------------------------------------------------------
set smarttab        " changes what value is used for tabs
set shiftround      " Round indent to multiple of 'shiftwidth' for < & >
set autoindent      " Auto indent when starting a new line
set shiftwidth=2    " number of spaces used to represent autoindents
set tabstop=2       " number of spaces a tab is represented by
set softtabstop=2   " how tabs behave in editing operations
set expandtab       " expand tabs to spaces


"-------------------------------------------------------------------------------
" Completion and search {1
"-------------------------------------------------------------------------------
set history=1000    " Longer history
set hlsearch        " Highlight searches
set ignorecase      " Do case insensitive matching
set smartcase       " Do smart case matching
set incsearch       " Start searching while I type
" set complete-=i   " Disable included file scanning in favor of tags


"-------------------------------------------------------------------------------
" Editing {1
"-------------------------------------------------------------------------------
set backspace=2                  " backspace over everything
set ofu=syntaxcomplete#Complete  " enable omnicomplete
set nrformats-=octal             " Disable incrementing and decrementing octals
set formatoptions+=or            " Automatically continue comments on new lines


"-------------------------------------------------------------------------------
" File reading and writing {1
"-------------------------------------------------------------------------------
set modeline          " Read modlines for file specific settings
set modelines=5       " Default number of lines to check
set autowrite         " Automatically save before commands like :next and :make
set autoread          " Automatically reload changed files
set fileformats+=mac  " Recognize mac line endings when reading a file


"-------------------------------------------------------------------------------
" Backup and undo {1
"-------------------------------------------------------------------------------
" Make backup dir if it doesn't exist
if !isdirectory(expand('~/.vim/backups'))
    call mkdir(expand('~/.vim/backups'), 'p')
endif

set backup                   " Automatic backups
set backupdir=~/.vim/backups " Where to save the automatic backups

" Older versions don't have this
if has('persistent_undo')
    " Make undo dir if it doesn't exist
    if !isdirectory(expand('~/.vim/undo'))
        call mkdir(expand('~/.vim/undo'), 'p')
    endif

    set undofile            " Enable persistent undo history
    set undodir=~/.vim/undo " Directory to save undo history in
    set undolevels=1000     " Max number of undos that can be done
    set undoreload=10000    " Max number of lines to save for undo
endif


"-------------------------------------------------------------------------------
" Toggle mappings{1
"-------------------------------------------------------------------------------
" Toggle line numbers
map <F1> :set number!<CR>

" Toggle relative line numbers
map <F2> :set relativenumber!<CR>

" Toggle paste mode
set pastetoggle=<F3>

" Toggle list
map <F4> :set list!<CR>

" Toggle crosshairs
map <F5> :let g:CROSSHAIRS = !g:CROSSHAIRS\| set cursorcolumn! cursorline!<CR>

" Toggle warn when going over 80 columns
map <F6> :call ToggleRightWarn()<CR>

" Toggle spell checking
map <F7> :set spell!<CR>


"-------------------------------------------------------------------------------
" Misc. Mappings {1
"-------------------------------------------------------------------------------
" Make Y behave like C and D
nnoremap Y y$

" Insert a break in the undo history before ctrl-u in insert mode
inoremap <C-U> <C-G>u<C-U>

" Keep the previous flags when rerunning the last substitution
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Clear highlighting
noremap <Leader><Space> :nohl<CR>

" Gain root privs if needed to write
command! Wsudo !sudo tee % > /dev/null %

" Hex mode
nnoremap <Leader>hon :%!xxd<CR>
nnoremap <Leader>hof :%!xxd -r<CR>

" Trim all trailing whitespace
nnoremap <Leader>ws :s/\s\+$//g<CR>
cnoremap <Leader>ws s/\s\+$//g<CR>
vnoremap <Leader>ws :s/\s\+$//g<CR>


"-------------------------------------------------------------------------------
" Helper functions {1
"-------------------------------------------------------------------------------
" Function to toggle warning when going over 80 columns
function! ToggleRightWarn()
    if !exists('b:RightWarn')
        if &textwidth
            let b:RightWarn = &textwidth + 1
        else
            let b:RightWarn = 81
        endif
        exe 'match Error /\%' . b:RightWarn. 'v.\+/'
        exe 'set colorcolumn=' . b:RightWarn
        exe 'let b:RightWarn =' . b:RightWarn
    else
        exe 'match None /\%' . b:RightWarn . 'v.\+/'
        set colorcolumn=
        unlet b:RightWarn
    endif
endfunction

function! s:HideTrailing()
    match None /\s\+$/
endfunction

function! s:ShowTrailing()
    if (!exists('b:hideTrailing') || !b:hideTrailing) &&
     \ (!exists('g:hideTrailing') || !g:hideTrailing)
        match TrailingWhitespace /\s\+$/
    endif
endfunction

" Handle setting up crosshairs in the current buffer
function! s:HandleCrosshairs(leaving)
    if !exists('g:CROSSHAIRS')
        let g:CROSSHAIRS = 1
    endif

    if a:leaving
        let g:CROSSHAIRS = &cursorcolumn && &cursorline
        setlocal nocursorline nocursorcolumn
    else
        if g:CROSSHAIRS
            setlocal cursorline cursorcolumn
        endif
    endif
endfunction


"-------------------------------------------------------------------------------
" Autocmd settings {1
"-------------------------------------------------------------------------------
if has("autocmd")

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    augroup jumpToPrevious
        au!
        autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif
    augroup end

    augroup hlToggle
        au!
        " Remove highlighting and trailing whitespace warning in insert mode
        au InsertEnter * set nohlsearch | call s:HideTrailing()
        au InsertLeave * set hlsearch | call s:ShowTrailing()
    augroup end

    " Crosshairs in current window
    augroup cursorCrosshairs
        au!
        au VimEnter,WinEnter,BufWinEnter * call s:HandleCrosshairs(0)
        au WinLeave * call s:HandleCrosshairs(1)
    augroup end

    " Cut trailing whitespace when writing a file
    " autocmd BufWritePre * :%s/\s\+$//e

endif


"-------------------------------------------------------------------------------
" Colorscheme and theming {1
"-------------------------------------------------------------------------------
" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux'
    set t_Co=16
endif

" set t_ut=
set background=dark
let g:solarized_termtrans = 1
colorscheme solarized

" Show trailing whitespace
highlight TrailingWhitespace ctermfg=1 ctermbg=NONE cterm=reverse
match TrailingWhitespace /\s\+$/


" vim: set tw=78 foldlevel=0 foldmarker={,} foldminlines=2 foldmethod=marker:
