# macOS /etc/zprofile runs path_helper, which puts system dirs first; re-apply zshenv's order.
(( $+functions[_dotfiles_path] )) && _dotfiles_path
unfunction _dotfiles_path 2>/dev/null

# Created by `pipx`
path+=($HOME/.local/bin)
