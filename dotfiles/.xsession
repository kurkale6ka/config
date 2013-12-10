# /etc/lightdm/lightdm.conf:
#
# user-session = xfce4-session
# session-wrapper = ~/.xsession
#
# ~/.gnupg/gpg-agent.conf
# disable-ssh-support

((SSH_AGENT_PID)) || eval "$(ssh-agent)"

export SSH_ASKPASS=pinentry
ssh-add "$HOME"/.ssh/id_rsa{,_git}
