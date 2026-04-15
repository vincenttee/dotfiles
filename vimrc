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
set statusline=%f\ %y\ %m\ %r\ %=%l/%L\ (%p%%)\ %c " custom status bar
set tabstop=4                   " number of spaces a tab counts for
set undodir=~/.vim/undodir      " directory for undo files
set undofile                    " maintain undo history between sessions
set ttimeoutlen=50              " faster key sequence timeout
set wildmenu                    " visual autocomplete for command menu

" move lines up/down with Option+j/k (macOS direct mappings)
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

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

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" Multi-cursor: Press 'C' in Visual Mode to add cursors to all selected lines
let g:VM_maps = {}
let g:VM_maps['Visual Cursors'] = 'C'
let g:VM_maps['Indent']         = '<Tab>'
let g:VM_maps['Outdent']        = '<S-Tab>'

" Allow Tab and Shift-Tab to indent/outdent in Visual Mode
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Standard Vim mappings for Tab/Shift-Tab in Normal mode
nnoremap <Tab> >>
nnoremap <S-Tab> <<

" Allow Shift-Tab to outdent in Insert Mode
inoremap <S-Tab> <C-d>

"Plug 'fatih/vim-go'
"Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

call plug#end() " initialize plugin system

" FZF Mappings
nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>f :Rg<Space>


