# test
ZSHUSER=$(whoami)
ZSHCUSTOMDIR=$HOME/.zsh-custom

if [[ $ZSHUSER == 'root' ]]
then
  ZSHUSERPATH=/root
  ZSHUSERCOLOUR=1
  ZSHUSERPROMPT=#
else
  ZSHUSERPATH=/home/$ZSHUSER
  ZSHUSERCOLOUR=2
  ZSHUSERPROMPT=$
fi

export PATH=/bin:/usr/bin:/usr/local/bin:$HOME/bin

HISTFILE=$ZSHCUSTOMDIR/history
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
zstyle :compinstall filename $ZSHUSERPATH/.zshrc

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }
# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{250}on %{%F{yellow}%}% %b'
# Set up the prompt (with git branch name)
setopt PROMPT_SUBST
#PROMPT='%n on ${PWD/#$HOME/~} ${vcs_info_msg_0_} > '

PROMPT='
%{%F{$ZSHUSERCOLOUR}%}%n %F{250}@ %{%F{37}%}%m %F{250}in %{%F{178}%}%~ ${vcs_info_msg_0_}
%F{250}$ZSHUSERPROMPT '

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}" reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
        autoload -Uz add-zle-hook-widget
        function zle_application_mode_start { echoti smkx }
        function zle_application_mode_stop { echoti rmkx }
        add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
        add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# https://github.com/zsh-users/zsh-autosuggestions
. $ZSHCUSTOMDIR/zz-plugin-zsh-autosuggestions.zsh

# auto-complete search history (command (up or down) to scroll through list of history that starts with command)
# https://github.com/zsh-users/zsh-history-substring-search
. $ZSHCUSTOMDIR/zz-plugin-zsh-history-substring-search.zsh
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# when pressing up/down it only shows unique history results
setopt HIST_FIND_NO_DUPS

# include zshrc-include if it exists
if [[ -f "$ZSHCUSTOMDIR/zshrc-include" ]]
then
    . $ZSHCUSTOMDIR/zshrc-include
fi
