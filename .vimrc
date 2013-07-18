" vim:fdm=marker

" The basics.
set nocompatible
set backspace=indent,eol,start

" Use Pathogen to manage Vim plugins.
filetype off
call pathogen#infect()

" Syntax handling and omnicompletion.
filetype plugin indent on
syntax on
set omnifunc=syntaxcomplete#Complete

" Mappings.
map Y y$

" Indenting and tabs.
set tabstop=4
set shiftwidth=4
set expandtab
set cinoptions=(0,u0
set cinwords=if,elif,else,for,while,try,except,finally,def,class

" Search options.
set incsearch
set nohlsearch
set ignorecase
set smartcase

" Line breaks.
set wrap
set linebreak
set joinspaces

" Status bar and tab-completion.
set laststatus=2
set wildmenu

" Buffer and window management.
set hidden
set scrolloff=1

" Miscellaneous.
set showmatch
autocmd FileType mail set nocin
colo xoria256

" Terminal-specific settings.
set ttyfast
set t_Co=256
set mouse=a

" MacVim/gVim-specific settings.
if has("gui_running")
    set guifont=Monaco:h9
    set guioptions-=T
    set lines=50
    set columns=100
    set foldcolumn=2
    set foldmethod=syntax
endif

" Override some distributions' overzealous fix for CVE-2007-2438
if version >= 701
    set modeline
    set modelines=5
endif

" LaTeX-Suite settings.  Assumes XeTeX on OS X.
set grepprg=grep\ -nh\ $*
let g:Tex_ViewRuleComplete_pdf = 'open -a Preview.app $*.pdf'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats = 'pdf'
let g:Tex_CompileRule_pdf = 'xelatex -interaction=nonstopmode $*'
let g:tex_flavor='latex'
