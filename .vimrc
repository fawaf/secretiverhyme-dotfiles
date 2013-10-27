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
set number
set showmatch
autocmd FileType mail set nocin
colo xoria256

" Terminal-specific settings.
set ttyfast
set t_Co=256
set mouse=a

" MacVim/gVim-specific settings.
if has("gui_running")
    colo mayansmoke
    set guifont=Monaco:h11
    set guioptions-=T
    set foldcolumn=2
    set foldmethod=syntax
endif

" Override some distributions' overzealous fix for CVE-2007-2438
if version >= 701
    set modeline
    set modelines=5
endif
