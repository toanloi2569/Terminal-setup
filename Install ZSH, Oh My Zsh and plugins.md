# Installing ZSH, Oh My Zsh, and setup Zsh plugins

## Installing Zsh
Zsh is a powerful shell with improved features over Bash. To install Zsh, run the following command:

```bash
sudo apt update
sudo apt install zsh
```

Verify the installation by checking the Zsh version:

```bash
zsh --version
```

Make Zsh your default shell by running:

```bash
chsh -s $(which zsh)
echo $SHELL # Verify the default shell
```

For more information, visit [Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)

## Installing Oh My 
Oh My Zsh is a framework for managing your Zsh configuration. To install Oh My Zsh, run the following command:

| Method | Command |
|--------|---------|
| curl   | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| wget   | `sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| fetch  | `sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |


## Setting up Zsh Plugins

Oh My Zsh comes with a variety of plugins that enhance your Zsh experience.   

To install a plugin, clone the plugin repository into the `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`). 

To enable a plugin, add it to the `plugins` array in `~/.zshrc`. For example, to enable the `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins, modify the `plugins` array as follows:

```bash
plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

### Zsh-Autosuggestions
[Zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) suggest commands as you type based on your command history. To install the plugin, run the following commands:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
```

### Zsh-Syntax-Highlighting
[Zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) is a plugin that highlights commands as you type based on syntax. To install the plugin, run the following commands:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
```

### Zsh-Completions
[Zsh-completions](https://github.com/marlonrichert/zsh-autocomplete) is a collection of extra completions for Zsh. To install the plugin, run the following commands:

```bash
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM}/plugins/zsh-autocomplete
```

### Fast-Syntax-Highlighting
[Fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) is a plugin that enables fast syntax highlighting in Zsh. To install the plugin, run the following commands:

```bash
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/fast-syntax-highlighting
```

## Additional Plugins

### Poetry
[Poetry](https://python-poetry.org/docs/) is a dependency management and packaging tool for Python. To install the Poetry plugin, run the following commands:

To install the plugin, install poetry by pipx:

```bash
sudo apt update
sudo apt install pipx
pipx ensurepath

pipx install poetry
```

Add poetry plugin:

```bash
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry
```

### Kube-ps1
[kube-ps1](https://github.com/jonmosco/kube-ps1) A script that lets you add the current Kubernetes context and namespace configured on kubectl to your Bash/Zsh prompt strings (i.e. the $PS1).  

kube-ps1 is included as a plugin in the oh-my-zsh project. To enable it, edit your ~/.zshrc and add the plugin:

```vim
plugins=(
  kube-ps1
)
PROMPT='$(kube_ps1)'$PROMPT # or RPROMPT='$(kube_ps1)'
```
