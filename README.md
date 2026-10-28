# Dotfiles

Personal macOS configuration files for Zsh, Vim, Tmux, Ghostty, Git, and CLI tooling.

## Contents

| File             | Description                                                                 |
| :--------------- | :-------------------------------------------------------------------------- |
| `zshenv`         | Environment variables, Homebrew setup, and `PATH` construction              |
| `zprofile`       | Restores `zshenv` `PATH` order after macOS `/etc/zprofile` (`path_helper`)  |
| `zshrc`          | Interactive shell options, cached tool completions, prompt, and helpers     |
| `developmentrc`  | Template for local/secret environment variables, sourced by `zshenv`        |
| `vimrc`          | Vim 9.1+ config with `vim-plug`, `fzf.vim`, `vim-go` (`gopls`), and Gruvbox |
| `tmux.conf`      | `Ctrl-a` prefix, vi mode, Gruvbox status bar, and TPM plugins               |
| `ghostty_config` | Ghostty theme and keybinds forwarded to Tmux                                |
| `gitconfig`      | Git defaults, `delta` pager, GPG signing, and aliases                       |
| `fzfrc`          | Default `fzf` layout and Gruvbox colors                                     |
| `ripgreprc`      | Default `rg` arguments (smart case, hidden files, `.git` excluded)          |
| `Brewfile`       | Homebrew formulae and casks                                                 |

Also included, not installed by the setup below:

- [`VIM.md`](VIM.md): Vim keybinding cheat sheet.
- `vscode/`: backup of VS Code `settings.json` and `keybindings.json`.
- `iterm2_profile/default.itermcolors`: legacy iTerm2 color preset (import via iTerm2 → Settings → Profiles → Colors).
- `vimium-options.json`: Vimium browser extension settings (import via Vimium options page).

## Setup

### 1. Clone and install packages

Install [Homebrew](https://brew.sh/), then clone the repository and install the bundle:

```bash
git clone https://github.com/vincenttee/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle --file=Brewfile
```

> Note: `ruby` (needed by `tmux-fzf-complete`) and `mysql-client` are keg-only in Homebrew. `zshenv` prepends their `opt/<pkg>/bin` directories to `PATH` automatically.

### 2. Symlink configuration files

Run from the repository root:

```bash
# Zsh
ln -sf "$PWD/zshenv" ~/.zshenv
ln -sf "$PWD/zprofile" ~/.zprofile
ln -sf "$PWD/zshrc" ~/.zshrc

# Vim, Tmux, Fzf, Ripgrep
ln -sf "$PWD/vimrc" ~/.vimrc
ln -sf "$PWD/tmux.conf" ~/.tmux.conf
ln -sf "$PWD/fzfrc" ~/.fzfrc
ln -sf "$PWD/ripgreprc" ~/.ripgreprc

# Ghostty (overrides ~/.config/ghostty/config on macOS)
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sf "$PWD/ghostty_config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
```

### 3. Install plugins and external scripts

```bash
# Vim undo directory and vim-plug
mkdir -p ~/.vim/undodir
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

# fzf-git.sh
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o ~/fzf-git.sh

# Tmux Plugin Manager (TPM)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Inside a running `tmux` session, press `Ctrl-a` then `Shift-i` to install Tmux plugins.

### 4. Local configuration

These files hold personal values, so copy them instead of symlinking to keep secrets and identity out of the repository:

```bash
cp "$PWD/gitconfig" ~/.gitconfig
cp "$PWD/developmentrc" ~/.developmentrc
```

- `~/.gitconfig`: replace `YOUR_NAME`, `YOUR_EMAIL`, `YOUR_GPG_KEY_ID`, and the `includeIf` work paths. `core.excludesfile` points to `~/.gitignore_global`, which is not part of this repository; create it yourself.
- `~/.developmentrc`: fill in `AWS_*`, `GOPRIVATE`, `WEATHER_LOCATION`, etc.

## Highlights

- **Fast shell startup**: `zshenv` hardcodes Homebrew paths instead of calling `brew shellenv`. `zshrc` caches `fzf`, `zoxide`, and `npm` init scripts in `~/.cache` (regenerated when the binary changes) and runs a full `compinit` check at most once per 24 hours. Run `ZSH_PROFILE=1 zsh -i -c exit` to profile startup with `zprof`.
- **Live content search (`fif` / `Ctrl-f`)**: `rg` results in `fzf` with a `bat` preview; `Enter` opens the match at its line in `$EDITOR`.
- **Ghostty → Tmux navigation**: `Cmd-Shift-[`/`]` (or `h`/`l`) switches Tmux windows; `Opt-Shift-[`/`]` (or `h`/`l`) switches sessions.

## Tests

Run the Zsh test suite to verify `PATH` precedence (both login and non-login shells) and Git prompt parsing:

```bash
zsh test/zshenv_path.zsh
zsh test/zshrc_git_prompt.zsh
```
