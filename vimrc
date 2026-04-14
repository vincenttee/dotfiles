syntax on
filetype indent on
filetype plugin indent on

set autoindent                  " copy indent from current line
set backspace=indent,eol,start  " fix backspace behavior
set clipboard=unnamed           " use system clipboard
set cursorline                  " highlight current line
set encoding=utf-8              " use utf-8 encoding
set expandtab                   " use spaces instead of tabs
set foldenable                  " enable folding
set foldlevelstart=10           " open most folds by default
set foldmethod=indent           " fold based on indent level
set foldnestmax=10              " 10 nested fold max
set hidden                      " allow switching buffers without saving
set hlsearch                    " highlight matches
set ignorecase                  " ignore case when searching
set incsearch                   " search as characters are entered
set laststatus=2                " always show statusline
set lazyredraw                  " redraw only when we need to
set number                      " show line numbers
set ruler                       " show the line and column number
set shiftwidth=4                " number of spaces for auto-indent
set showcmd                     " show command in bottom bar
set showmatch                   " highlight matching [{()}]
set smartcase                   " case-sensitive if query has caps
set tabstop=4                   " number of spaces a tab counts for
set undodir=~/.vim/undodir      " directory for undo files
set undofile                    " maintain undo history between sessions
set wildmenu                    " visual autocomplete for command menu

" move lines up/down with Option+j/k
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==

inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi

vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" allows cursor change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif


" Plugins
"call plug#begin('~/.vim/plugged')

"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"Plug 'fatih/vim-go'
"Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

"call plug#end() " initialize plugin system

