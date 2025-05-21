# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"


plugins=(
    git
    nvm
    poetry
    kube-ps1
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autocomplete
    you-should-use
)

source $ZSH/oh-my-zsh.sh

source ~/.profile

source ~/.zshrc.d/shell-funcs/k8s_helpers.sh
source ~/.zshrc.d/shell-funcs/git_helpers.sh
source ~/.zshrc.d/alias.sh


# Conda setup
__conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

export CONDA_PROMPT_MODIFIER=""
PROMPT='$(kube_ps1)'$PROMPT


# Setup kubectl alias
[ -f ~/.zshrc.d/kubectl_aliases ] && source ~/.zshrc.d/kubectl_aliases
function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }


# Setup kube krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


# Setup k8s context config
DEFAULT_KUBECONFIG_FILE="$HOME/.kube/config"
DEFAULT_KUBECONFIG_FILE_BACKUP="$HOME/.kube/config.bak"
if test -f "${DEFAULT_KUBECONFIG_FILE}"
then
  export KUBECONFIG="$DEFAULT_KUBECONFIG_FILE"
fi
# Your additional kubeconfig files should be inside ~/.kube/ and named kubeconfig.*.yml or kubeconfig.*.yaml
OIFS="$IFS"
IFS=$'\n'
for kubeconfigFile in `find "$HOME/.kube/" -type f -name "kubeconfig.*.yml" -o -name "kubeconfig.*.yaml"`
do
  export KUBECONFIG="$kubeconfigFile:$KUBECONFIG"
done
IFS="$OIFS"
cp ${DEFAULT_KUBECONFIG_FILE} ${DEFAULT_KUBECONFIG_FILE_BACKUP} && kubectl config view --flatten > /tmp/config && mv /tmp/config ${DEFAULT_KUBECONFIG_FILE}
export KUBECONFIG="$DEFAULT_KUBECONFIG_FILE"


# Setup gvm
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
}


bindkey '^H' backward-kill-word


eval "$(starship init zsh)"
eval "$(zoxide init zsh)"