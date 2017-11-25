syntax on
filetype indent on
filetype plugin indent on

set cursorline          " highlight current line
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldmethod=indent   " fold based on indent level
set foldnestmax=10      " 10 nested fold max
set hlsearch            " highlight matches
set incsearch           " search as characters are entered
set laststatus=2        " always show statusline
set lazyredraw          " redraw only when we need to
set number              " show line numbers
set ruler               " show the line and column number of the cursor position
set showcmd             " show command in bottom bar
set showmatch           " highlight matching [{()}]
set wildmenu            " visual autocomplete for command menu
set backspace=indent,eol,start " fix backspace not working

" allows cursor change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif


" Plugins
call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'fatih/vim-go'
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

call plug#end() " initialize plugin system
