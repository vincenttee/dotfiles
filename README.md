# Vincent's Dotfiles

My personal collection of configuration files for macOS.

## Included Configurations

- **Vim (`vimrc`)**: Persistent undo, fzf fuzzy finding, and line manipulation.
- **Zsh (`zshrc`, `zshenv`)**: Shell aliases and environment settings (`zprofile` restores the `PATH` order in login shells).
- **Ripgrep (`ripgreprc`)**: Search defaults and exclusions.
- **Fzf (`fzfrc`)**: Default fzf options.
- **Git (`gitconfig`)**: Global defaults and exclusions.
- **Ghostty (`ghostty_config`)**: Terminal settings and tmux navigation keybinds.
- **Tmux (`tmux.conf`)**: Terminal multiplexing.
- **Homebrew (`Brewfile`)**: macOS apps and CLI tools.
- **VS Code (`vscode/`)**: Keybindings and settings.

## Installation

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

The Brewfile includes Homebrew `ruby`, which `tmux-fzf-complete` requires (the system Ruby is too old). It is keg-only, so `zshenv` puts it on `PATH`.

### 3. Setup Symbolic Links & Scripts

Run these commands from within the cloned repository directory to link the configuration files to your home directory and fetch the external scripts:

```bash
# Vim
ln -sf $(pwd)/vimrc ~/.vimrc
mkdir -p ~/.vim/undodir

# Install vim-plug and plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

# Zsh
ln -sf $(pwd)/zshrc ~/.zshrc
ln -sf $(pwd)/zshenv ~/.zshenv
ln -sf $(pwd)/zprofile ~/.zprofile  # re-applies PATH order after macOS path_helper

# Ripgrep
ln -sf $(pwd)/ripgreprc ~/.ripgreprc

# Fzf (re-run the curl to update fzf-git.sh)
ln -sf $(pwd)/fzfrc ~/.fzfrc
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o ~/fzf-git.sh

# Git
ln -sf $(pwd)/gitconfig ~/.gitconfig

# Ghostty (macOS reads this path and it overrides ~/.config/ghostty/config)
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
ln -sf $(pwd)/ghostty_config ~/Library/Application\ Support/com.mitchellh.ghostty/config

# Tmux
ln -sf $(pwd)/tmux.conf ~/.tmux.conf

# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 4. Install Tmux Plugins

Start tmux and press `prefix + I` (`Ctrl-a`, then `Shift-i`) to install the plugins, including `tmux-fzf-complete`.
