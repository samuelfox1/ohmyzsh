function curr_git_status() {
  tester=$(git rev-parse --git-dir 2> /dev/null) || return
  
  local INDEX=$(git status --porcelain 2> /dev/null)
  local STATUS_STAGED=""
  local STATUS_B=""

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
    STATUS_STAGED="$STATUS_STAGED$ZSH_THEME_GIT_PROMPT_STAGED"
  fi

  # is anything unstaged?
  if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
    STATUS_STAGED="$STATUS_STAGED$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi

  # is anything untracked?
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS_B="$STATUS_B$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi


  # is branch ahead?
  if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS_B="$STATUS_B$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi

  # is branch behind?
  if $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS_B="$STATUS_B$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi

  # is anything unmerged?
  if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
    STATUS_B="$STATUS_B$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi


  if [[ $STATUS_STAGED = $ZSH_THEME_GIT_PROMPT_UNSTAGED ]]; then
    STATUS_STAGED="${styled_colon}$STATUS_STAGED"
  fi

  if [[ $STATUS_STAGED = $ZSH_THEME_GIT_PROMPT_STAGED ]]; then
    STATUS_STAGED="$STATUS_STAGED${styled_colon}"
  fi

  if [[ $STATUS_STAGED = "" ]]; then
    STATUS_STAGED="${styled_colon}${styled_colon}"
  fi

  echo "$STATUS_STAGED$(my_current_gitbranch) $STATUS_B"
}

function my_current_gitbranch() {
  local CUSTOM_BRANCH_FORMAT="(no branch)"
  
  if [[ -n $(git_current_branch)  ]]; then
  CUSTOM_BRANCH_FORMAT="%F{${c_yellow}}$(git_current_branch)"
  fi
  echo ${CUSTOM_BRANCH_FORMAT}
}

function if_ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[red]%}(ssh):"
  fi
}

# # # # # # # # # # #
# TOOLS & MATERIALS #
# # # # # # # # # # #
# LIST COLORS 0-255: $ spectrum_ls
local c_grey=008
local c_green=042
local c_red=009
local c_yellow=003
local c_orange=214

local c_terminal_success=${c_green}
local c_terminal_error=${c_red}
local curr_directory="%F{${c_orange}}%1/"
local curr_return_status="%?"

# # # # # # # # # # #
# STYLED COMPONENTS #
# # # # # # # # # # #
local styled_colon="%F{${c_grey}}:"
local styled_user="%F{${c_grey}}%n"
local styled_directory="${styled_colon}${curr_directory}"
local styled_terminal_input="%(?:%F{${c_terminal_success}}:%F{${c_terminal_error}})$%f"

ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[magenta]%}↑"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[green]%}↓"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}:"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}:"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[white]%}+"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}✕"

PROMPT=$'\n$(if_ssh_connection)${styled_user}${styled_directory}$(curr_git_status)\n${styled_terminal_input} '
