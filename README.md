# Vincent's Dotfiles

My personal collection of configuration files for macOS.

## 🧰 Included Configurations

- **Vim (`vimrc`)**: Persistent undo, fzf fuzzy finding, and line manipulation.
- **Zsh (`zshrc`, `zshenv`)**: Shell aliases and environment settings.
- **Git (`gitconfig`)**: Global defaults and exclusions.
- **Tmux (`tmux.conf`)**: Terminal multiplexing.
- **Homebrew (`Brewfile`)**: macOS apps and CLI tools.
- **VS Code (`vscode/`)**: Keybindings and settings.

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/vincenttee/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install Dependencies (Homebrew)
If you don't have Homebrew installed, [install it first](https://brew.sh/).
```bash
brew bundle --file=Brewfile
```

### 3. Setup Symbolic Links
Use these commands to link the configuration files to your home directory:

```bash
# Vim
ln -sf ~/dotfiles/vimrc ~/.vimrc
mkdir -p ~/.vim/undodir

# Install vim-plug and plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

# Zsh
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/zshenv ~/.zshenv

# Git
ln -sf ~/dotfiles/gitconfig ~/.gitconfig

# Tmux
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
```
