"-------------------------------------------------------------------------------
" Load plugins and set up mappings and options
"-------------------------------------------------------------------------------
" Minimum requirements for plugins
if version < 702 || !has('autocmd')
    echoerr 'This vim is to old for plugins :(.'
    finish
endif

" Check if we need to install vim-plug {2
let s:plug_file=expand(g:configdir . 'autoload/plug.vim')
if !filereadable(s:plug_file)
    echo "Installing vim-plug...\n"
    exec('silent !curl -fLo ' . g:configdir . '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
endif

" Required
"let g:python3_host_prog = '/usr/local/bin/python3'
call plug#begin(g:configdir . '/plugged')


"" Plugins that work in stand-alone or embedded neovim

" Core {1
Plug 'editorconfig/editorconfig-vim'

" Movement / Editing {1
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-speeddating'
Plug 'justinmk/vim-sneak'
"{
    nmap <Leader>s <Plug>Sneak_s
    nmap <Leader>S <Plug>Sneak_S
    xmap <Leader>s <Plug>Sneak_s
    xmap <Leader>S <Plug>Sneak_S
    omap <Leader>s <Plug>Sneak_s
    omap <Leader>S <Plug>Sneak_S
    let g:sneak#streak = 1
"}
Plug 'junegunn/vim-easy-align'
Plug 'gregsexton/MatchTag'
Plug 'tomtom/tcomment_vim'
"{
    xmap gcb :TCommentBlock<CR>
    xmap gcc :TComment<CR>
"}
Plug 'Raimondi/delimitMate'
"{
    " expand space and cr inside pairs
    let g:delimitMate_expand_cr = 2
    let g:delimitMate_expand_space = 1
    let g:delimitMate_jump_expansion = 1
    " fix triple quoted strings in python
    au FileType python let b:delimitMate_nesting_quotes = ["'"]
"}
Plug 'SirVer/ultisnips'
"{
    " Name used by some snippets
    let g:snips_author = 'Joshua Matthews'
    " let g:UltiSnipsExpandTrigger="<c-k>"
    " inoremap <silent> <expr> <CR> ((pumvisible() && empty(v:completed_item)) ?  "\<c-y>\<cr>" : (!empty(v:completed_item) ? ncm2_ultisnips#expand_or("", 'n') : "\<CR>" ))
    inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')
    imap <expr> <c-u> ncm2_ultisnips#expand_or("\<Plug>(ultisnips_expand)", 'm')
    smap <c-u> <Plug>(ultisnips_expand)
    let g:UltiSnipsExpandTrigger		= "<Plug>(ultisnips_expand)"
    let g:UltiSnipsJumpForwardTrigger	= "<c-k>"
    let g:UltiSnipsJumpBackwardTrigger	= "<c-h>"
    let g:UltiSnipsRemoveSelectModeMappings = 0


    " let g:UltiSnipsListSnippets="<c-l>"
    " imap <C-l> <ESC>:Denite -start-insert ultisnips<CR>
"}
Plug 'honza/vim-snippets'

"" Plugins that only work in stand-alone neovim

if !exists('g:vscode')
  " Core {1
  Plug 'chrisbra/SudoEdit.vim'
  Plug 'tpope/vim-vinegar'
  Plug 'roxma/nvim-yarp'


  " Movement / Editing {1
  Plug 'mg979/vim-visual-multi'
  Plug 'mbbill/undotree', {'on':'UndotreeToggle'}
  Plug 'honza/vim-snippets'
  Plug 'preservim/nerdtree'
  "{
      nnoremap <silent> <Leader>dd :NERDTree<CR>
      nnoremap <silent> <Leader>df :NERDTreeFind<CR>
  "}
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'junegunn/fzf.vim'
  "{
      nnoremap <Leader>f :GFiles<CR>
      nnoremap <Leader>b :Buffers<CR>
      nnoremap <Leader>b :Buffers<CR>
      nnoremap <Leader>r :Rg<CR>
  "}

  " Development {1
  Plug 'tpope/vim-fugitive', { 'augroup' : 'fugitive'}
  "{
      nnoremap <Leader>gd :Gdiff<CR>
      nnoremap <Leader>gs :Gstatus<CR>
  "}
  if has('signs')
      Plug 'airblade/vim-gitgutter'
  endif
  Plug 'majutsushi/tagbar'  "{
      nnoremap <silent> <Leader>t :TagbarOpenAutoClose<CR>
  "}
  Plug 'kien/rainbow_parentheses.vim',
  "{
      \ {'for':['lisp', 'scheme']}
      " Set custom rainbow paren colors
      let g:rbpt_colorpairs = [
          \ ['brown',       'RoyalBlue3'],
          \ ['Darkblue',    'SeaGreen3'],
          \ ['darkgray',    'DarkOrchid3'],
          \ ['darkgreen',   'firebrick3'],
          \ ['darkred',     'SeaGreen3'],
          \ ['darkcyan',    'RoyalBlue3'],
          \ ['darkmagenta', 'DarkOrchid3'],
          \ ['grey',        'RoyalBlue3'],
          \ ['brown',       'firebrick3'],
          \ ['darkgray',    'SeaGreen3'],
          \ ['darkmagenta', 'DarkOrchid3'],
          \ ['Darkblue',    'firebrick3'],
          \ ['darkgreen',   'RoyalBlue3'],
          \ ['darkred',     'DarkOrchid3'],
          \ ['darkcyan',    'SeaGreen3'],
          \ ['red',         'firebrick3'],
          \ ]
  Plug 'ncm2/ncm2'
  "{
      autocmd BufEnter * call ncm2#enable_for_buffer()
      " IMPORTANT: :help Ncm2PopupOpen for more information
      set completeopt=noinsert,menuone,noselect

      " NOTE: you need to install completion sources to get completions. Check
      " our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
      Plug 'ncm2/ncm2-bufword'
      Plug 'ncm2/ncm2-path'
      Plug 'ncm2/ncm2-go'
      Plug 'ncm2/ncm2-ultisnips'
      "{
          " " Press enter key to trigger snippet expansion
          " " The parameters are the same as `:help feedkeys()`
          " inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')
          "
          " " c-j c-k for moving in snippet
          " let g:UltiSnipsExpandTrigger		= "<Plug>(ultisnips_expand)"
          " let g:UltiSnipsJumpForwardTrigger	= "<c-k>"
          " let g:UltiSnipsJumpBackwardTrigger	= "<c-h>"
          " let g:UltiSnipsRemoveSelectModeMappings = 0
      "}
  "}

  "}
  " Plug 'autozimu/LanguageClient-neovim', {
  "     \ 'branch': 'next',
  "     \ 'do': 'bash install.sh',
  " \ }
  " "{
  "     let g:LanguageClient_hasSnippetSupport = 1
  "     let g:LanguageClient_serverCommands = {
  "         \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
  "         \ 'go': ['gopls'],
  "     \ }
  "     for lscLang in keys(g:LanguageClient_serverCommands)
  "         exec 'au FileType ' . lscLang . ' nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>'
  "         exec 'au FileType ' . lscLang . ' nnoremap <silent> <C-p> :call LanguageClient#textDocument_hover()<CR>'
  "         exec 'au FileType ' . lscLang . ' nnoremap <silent> <F5> :call LanguageClient_contextMenu()<CR>'
  "         exec 'au FileType ' . lscLang . ' nnoremap <silent> <C-N> :call LanguageClient#textDocument_rename()<CR>'
  "         exec 'au FileType ' . lscLang . ' nnoremap <silent> <Leader>i :call LanguageClient_textDocument_hover()<CR>'
  "         " exec 'nnoremap <F5> :call LanguageClient_contextMenu()<CR>'
  "     endfor
  "     " let g:LanguageClient_loggingFile =  expand('~/langclient.log')
  "     " let g:LanguageClient_loggingLevel = 'DEBUG'
  " "}

  " Support for extra filetypes {1
  Plug 'jceb/vim-orgmode', {'for':['org']}
  Plug 'digitaltoad/vim-jade', {'for':['jade']}
  Plug 'saltstack/salt-vim', {'for':['sls']}
  Plug 'wavded/vim-stylus', {'for':['stylus']}
  Plug 'cespare/vim-toml', {'for':['toml']}
  Plug 'mustache/vim-mustache-handlebars', {'for':['html']}
  Plug 'chaquotay/ftl-vim-syntax', {'for':['ftl']}
  Plug 'fatih/vim-go', {'for':['go'], 'do': ':GoInstallBinaries'}
  "{
      let g:go_disable_autoinstall = 1

      let g:go_fmt_fail_silently = 1

      " Show a list of interfaces which is implemented by the type under your cursor
      " au FileType go nmap <Leader>s <Plug>(go-implements)

      " Show type info for the word under your cursor
      " au FileType go nmap <Leader>i <Plug>(go-info)

      " Open the relevant Godoc for the word under the cursor
      " au FileType go nmap <Leader>gd <Plug>(go-doc)
      " au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)

      " Open the Godoc in browser
      " au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

      " Run/build/test/coverage
      " au FileType go nmap <leader>r <Plug>(go-run)
      " au FileType go nmap <leader>b <Plug>(go-build)
      " au FileType go nmap <leader>t <Plug>(go-test)
      " au FileType go nmap <leader>c <Plug>(go-coverage)

      " By default syntax-highlighting for Functions, Methods and Structs is disabled.
      " Let's enable them!
      let g:go_highlight_functions = 1
      let g:go_highlight_methods = 1
      let g:go_highlight_structs = 1

      let g:go_def_mode='gopls'
      let g:go_info_mode='gopls'
  "}
  Plug 'rust-lang/rust.vim'
  "{
      let g:rust_recommended_style = 0
      let g:rustfmt_autosave = 1
  "}
  Plug 'suan/vim-instant-markdown'
  "{
      let g:instant_markdown_autostart = 0
  "}
  Plug 'mxw/vim-jsx'
  Plug 'posva/vim-vue'
  Plug 'leafgarland/typescript-vim'
  Plug 'Quramy/tsuquyomi'


  " Fun Extras {1
  Plug 'vim-airline/vim-airline'
  "{
      let g:airline_powerline_fonts = 1
  "}
  Plug 'vim-airline/vim-airline-themes'
  "{
      let g:airline_solarized_normal_green = 1
      let g:airline_solarized_dark_inactive_border = 1
  "}
  Plug 'junegunn/limelight.vim', {'on': 'Limelight'}
  "{
    let g:limelight_conceal_ctermfg = 10
  "}
  Plug 'junegunn/goyo.vim', {'on': 'Goyo'}
  "{
    let g:goyo_width = 120
    nnoremap <Leader>gy :GitGutterToggle<CR> :Goyo<CR>
    function! s:goyo_enter()
      " silent !tmux set status off
      " silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
      set noshowmode
      set noshowcmd
      set scrolloff=999
      Limelight
      GitGutterDisable
    endfunction

    function! s:goyo_leave()
      " silent !tmux set status on
      " silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
      set showmode
      set showcmd
      set scrolloff=5
      Limelight!
      GitGutterEnable
    endfunction

    autocmd! User GoyoEnter nested call <SID>goyo_enter()
    autocmd! User GoyoLeave nested call <SID>goyo_leave()
  "}

  " Colorscheme bundles {1
  Plug 'ciaranm/inkpot'
  Plug 'tomasr/molokai'
  Plug 'tpope/vim-vividchalk'
  Plug 'w0ng/vim-hybrid'
  Plug 'vim-scripts/corporation'
  Plug 'whatyouhide/vim-gotham'
  Plug 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
endif

call plug#end()

" Turn filetype back on
filetype plugin indent on

" Trigger any remaining setup
doautocmd User PlugDone

" vim: set tw=78 foldlevel=1 foldmarker={,} foldminlines=2 foldmethod=marker:
