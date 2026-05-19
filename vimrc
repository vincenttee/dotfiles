syntax on
filetype indent on
filetype plugin indent on

set autoread                    " reload files changed outside vim
set history=500                 " remember more commands and search history
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
set scrolloff=15                " keep 15 lines of padding when scrolling
set ruler                       " show the line and column number
set shiftwidth=2                " number of spaces for auto-indent
set showcmd                     " show command in bottom bar
set showmatch                   " highlight matching [{()}]
set smartcase                   " case-sensitive if query has caps
set statusline=%f\ %y\ %m\ %r\ %=%l/%L\ (%p%%)\ %c " custom status bar
set tabstop=2                   " number of spaces a tab counts for
set undodir=~/.vim/undodir      " directory for undo files
set undofile                    " maintain undo history between sessions
set ttimeoutlen=50              " faster key sequence timeout
set wildmenu                    " visual autocomplete for command menu
set termguicolors               " enable true colors support
set regexpengine=0              " Use automatic regexpengine

" Map Opt+Backspace (Alt+BS) to delete previous word in Insert/Command mode
inoremap <M-BS> <C-w>
cnoremap <M-BS> <C-w>
" Fallback for terminals sending Esc + Backspace
inoremap <Esc><BS> <C-w>
cnoremap <Esc><BS> <C-w>
inoremap <Esc><C-h> <C-w>
cnoremap <Esc><C-h> <C-w>

" Theme Configuration
set background=dark
let g:gruvbox_italic=1
let g:tokyonight_style = 'night' " options: night, storm

" move lines up/down with Alt/Option + j/k
" Note: Ghostty macos-option-as-alt = true sends Esc+j/k
" Standard Vim needs explicit keycode settings for Meta keys
if !has('nvim')
  execute "set <M-j>=\e" . "j"
  execute "set <M-k>=\e" . "k"
endif

nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

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
Plug 'airblade/vim-gitgutter'

" Themes
Plug 'morhetz/gruvbox'
Plug 'ghifarit53/tokyonight-vim'

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

Plug 'fatih/vim-go', { 'for': 'go' }

call plug#end() " initialize plugin system

" vim-go configuration
let g:go_def_mode='gopls'          " Use gopls for definition jumps
let g:go_info_mode='gopls'         " Use gopls for hover/info
let g:go_fmt_command = "goimports" " Auto-format and fix imports on save
let g:go_auto_type_info = 1        " Show type info in status line automatically
let g:go_diagnostics_enabled = 0   " Disable integrated linter (gopls does this better)

" Syntax Highlighting
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1

" Essential Mappings for Go
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>b <Plug>(go-build)
autocmd FileType go nmap <leader>c :GoReferrers<CR>
autocmd FileType go nmap <F2> <Plug>(go-rename)
autocmd FileType go nmap <leader>a <Plug>(go-alternate) " Toggle between file.go and file_test.go

" FZF + Go Symbols
let g:go_decls_mode = 'fzf'
let g:fzf_layout = { 'down': '~40%' } " Avoid popup window to fix E863 error

autocmd FileType go nmap <leader>s :GoDecls<CR>
autocmd FileType go nmap <leader>S :GoDeclsDir<CR>

" UI & Performance
let g:go_list_type = "quickfix"    " Use quickfix for all error lists
let g:go_list_height = 15         " Increase height of the quickfix window
let g:go_echo_command_info = 1    " Echo progress in the command line
let g:go_gopls_enabled = 1        " Ensure gopls is the backend

" Refresh buffer, clear search highlighting, and redraw screen
nnoremap <C-L> :checktime<CR>:noh<CR><C-L>

" Close quickfix and preview windows
nnoremap <leader>q :cclose<CR>:pclose<CR>

" Toggle paste mode
nnoremap <leader>pp :set invpaste paste?<CR>

" Quickfix Navigation Mappings
nnoremap <leader>n :cnext<CR>
nnoremap <leader>p :cprev<CR>

" Buffer Navigation (Cycle through open files)
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap <leader><leader> <C-^> " Double-leader to toggle between last two files

" Prevent deletion/change from overriding the yank register
nnoremap x "_x
nnoremap d "_d
vnoremap d "_d
nnoremap D "_D
vnoremap D "_D
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C
vnoremap C "_C

" Standardize Y to yank to end of line
nnoremap Y y$

colorscheme gruvbox

" FZF Mappings
nnoremap <C-p> :Files<CR>
nnoremap <leader>gs :GFiles?<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>f :Rg<Space>

" Formatting: Define :Format and allow lowercase :format via abbreviation
command! Format normal! gg=G``
cabbrev format Format

" Delete trailing white space on save
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.go,*.py,*.js,*.ts,*.php,*.rs,*.txt :call CleanExtraSpaces()
endif


