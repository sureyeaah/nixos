" general settings
set number relativenumber
set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
set showcmd
set wildmenu
set incsearch
set hlsearch
set mouse=a
set clipboard=unnamedplus
set autoread
set hidden
set termguicolors
set nobackup
set nowritebackup
set timeoutlen=500

" colors, font, syntax
"
"
filetype plugin indent on
syntax on 
set t_Co=256
set encoding=utf-8
set background=dark
colorscheme spaceduck 
let g:gruvbox_bold = 1
let g:gruvbox_contrast_dark = 'hard'
autocmd BufRead *.sql set filetype=mysql      
set cmdheight=2
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes
set cursorline

" bindings
let mapleader = " "
nmap <F2> :mksession! ~/.vim_session<CR> 
nmap <F3> :source ~/.vim_session<CR> 
nmap <C-A> ggvG$
vmap <C-C> "+y
nmap <C-C> "+yy
map <leader>p "+p
map <C-S> :w<CR>

" clear search
map <C-l> :noh<CR>

" buffers
nmap <leader>n :enew<cr>
nmap <leader>l :bn<CR>
nmap <leader>h :bp<CR>
nmap <leader>bl :ls<CR>
nmap <leader>d :BD<CR>

" Move between splits
nnoremap <leader>mh <C-w>h
nnoremap <leader>mj <C-w>j
nnoremap <leader>mk <C-w>k
nnoremap <leader>ml <C-w>l

" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" Airline
let g:airline#extensions#tabline#enabled  = 1
let g:airline_powerline_fonts             = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_theme                       = 'spaceduck'
let g:airline_powerline_fonts             = 1

" Tabular
nmap <Leader>t= :Tabularize /=<CR>
vmap <Leader>t= :Tabularize /=<CR>
nmap <Leader>t: :Tabularize /:\zs<CR>
vmap <Leader>t: :Tabularize /:\zs<CR>

" NERDtree
autocmd StdinReadPre * let s:std_in=1
"Toggle NERDTree with Ctrl-N
nnoremap <C-n> :NERDTreeFind<CR>
nnoremap <A-n> :NERDTreeToggle<CR>
"Show hidden files in NERDTree
let NERDTreeShowHidden = 1

" ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['METADATA']
if executable('rg')
  set grepprg=rg\ --hidden\ --color=never
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = 'rg --files --hidden --color=never * %s'
elseif executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
    \ --ignore .git
    \ --ignore .svn
    \ --ignore .hg
    \ --ignore .DS_Store
    \ --ignore "**/*.pyc"
    \ --ignore review
    \ -g ""'
endif

"autoload
let g:session_autoload = 'no'

" haskell
autocmd Filetype haskell setlocal formatprg=ormolu
let g:cabal_indent_section            = 2
let g:haskell_backpack                = 1                " to enable highlighting of backpack keywords
let g:haskell_classic_highlighting    = 1
let g:haskell_enable_quantification   = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo      = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax      = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles        = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers  = 1  " to enable highlighting of `static`
let g:haskell_indent_if               = 3
let g:haskell_indent_case             = 2
let g:haskell_indent_let              = 4
let g:haskell_indent_where            = 6
let g:haskell_indent_before_where     = 2
let g:haskell_indent_after_bare_where = 2
let g:haskell_indent_do               = 3
let g:haskell_indent_in               = 1
let g:haskell_indent_guard            = 2
let g:haskell_indent_case_alternative = 1

" purescript
let purescript_indent_if = 3
let purescript_indent_case = 5
let purescript_indent_let = 4
let purescript_indent_where = 6
let purescript_indent_do = 3
let purescript_indent_in = 1
let purescript_indent_dot = v:true

" indentline
autocmd Filetype json let g:indentLine_enabled = 0
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_setConceal = 2
let g:indentLine_concealcursor = ""
