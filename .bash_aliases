# ~/.bash_aliases: store my aliases in a different file - .bashrc was getting
#                  too clobbered

# Avoid re-reading this file unless explicitly asked by the alias 'resource'
if [ "$BASH_ALIASES_READ" != yes ]; then
BASH_ALIASES_READ=yes

#echo "Reading .bash_aliases"

# Easy way to reload ~/.bashrc (and thus ~/.bash_aliases
alias resource='BASHRC_READ=no BASH_ALIASES_READ=no source ~/.bashrc'

# If user is not root, run those commands with sudo
if [ $UID -ne 0 ]; then
	alias shutdown='sudo shutdown -P now'
	alias reboot='sudo shutdown -r now'
	alias hibernate='sudo pm-hibernate'
fi

# Dim off the screen on X (returns after keypress or mouse movement)
alias off='xset dpms force off'

# Verbose commands
alias mkdir='mkdir -v'
alias rmdir='rmdir -v'
alias rm='rm -vi'	   # Safety check for deleting files (overwrite with -f)
alias cp='cp -v'

alias l='ls -CF'

# Time savers
function mkdircd () {
	mkdir -pv "$@" && eval cd "\"\$$#\""
}
function cdls () {
	cd "$@" && pwd && ls
}
alias '..'='cdls ..'
alias '...'='cdls ../..'

# Pretty printers
alias mmount='mount | column -t' # need to pass parameters to the mount command - not column

# Cleaning up my 'Trash' (sometimes files deleted on ~ appear here)
alias empty_trash="rm -rf ~/.Trash-1000/files/* ~/.Trash-1000/info/* ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*"

################################################################################
# Local installs

# Awesome stallman cowsay.
# The file: https://raw.github.com/archhurd/packages/master/extra/cowsay/rms.cow
alias vrms='vrms | cowsay -f rms'
alias rmsfortune='fortune | cowsay -f rms -W 80'

# make `less` more friendly for non-text input files, see lesspipe(1)
[ -x ~/.lesspipe.sh ] && eval "$(SHELL=/bin/bash ~/.lesspipe.sh)"

# `less` with syntax-highlighted output.
# Depends on the package `source-highlight`
export LESSOPEN='| /usr/bin/src-hilite-lesspipe.sh %s'
export LESS='-R -x4'

# This works on Ubuntu/Debian
# Previous works on Arch
#export LESSOPEN='| /usr/share/source-highlight/src-hilite-lesspipe.sh %s'

# Pretty output for the Network Manager's commandline interface
alias nmcli='nmcli -p --nocheck'

# My help documents
alias tips="cat ~/tips"
alias keys="cat ~/keys"
alias idea="cat >> ~/Desktop/ideas.txt"

################################################################################
# Util Functions

# Get external ip address through www.icanhazip.com
function eip() {
	wget -q -O - www.icanhazip.com
	if [ $? -ne 0 ]; then
		echo "Error connecting to internet";
	fi
}

# A simple cheatsheet to uncompress files
function extract-help() {
	echo "file.tar.bz2_tar -xvjf file
file.tar.gz___tar -xvzf file
file.bz2______bunzip2 file
file.rar______rar x file
file.gz_______gunzip file
file.tar______tar -xvf file
file.tbz2_____tar -xvjf file
file.tgz______tar -xvzf file
file.zip______unzip file
file.Z________uncompress file
file.7z_______7z x file"
}

# A function to help extract Lua's .love files
function love-unzip() {
	cp "$1.love" "$1.zip"
	mkdir "$1"
	mv "$1.zip" "$1"
	cd "$1"
	unzip "$1.zip"
	rm -f "$1.zip"
	cd ..
}

# Util that gives me a short wikipedia summary of a word
function wiki() {
	dig +short txt $1.wp.dg.cx | sed -e 's|" "||g' -e 's|http|\nAddress: http:|g' | fmt -w 80 -t | tr -d '"'
}

# Shortcut for extracting .rar file on a folder with same name
function winrar () {
	DIRNAME="WINRARTMP"
	FILENAME=$@

	mkdir -v $DIRNAME
	mv $FILENAME $DIRNAME
	pushd $DIRNAME
	unrar e $FILENAME
	rm -fv $FILENAME
	popd
	mv $DIRNAME $FILENAME
}

# Get internal ip address
alias iip='ip a'

# Copies file with progress bar
function cp_progress_bar()
{
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
		| awk '{
			count += $NF
				if (count % 10 == 0) {
					percent = count / total_size * 100
					printf "%3d%% [", percent
					for (i=0; i<=percent; i++)
						printf "="
					printf ">"
					for (i=percent; i < 100; i++)
						printf " "
					printf "]\r"
				}
		   }
		   END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# Advanced copy and move
#alias cp='acp --progress-bar'
#alias mv='amv --progress-bar'

# This was an attempt to make the prompt color change if the current
# directory is empty.
# It worked, but has two major flaws (because it wraps-up the 'cd' command)
#  * It recognizes only when I 'cd' into an empty dir - if a file is created
#	 immediately, the prompt still keeps the 'isEmpty' color
#  * When I try to go into my home dir, sending no parameters to 'cd', it
#	 does nothing - and keeps me on the current dir.
# The only way I though it would work was to change $PS1 whenever I
# change directory through 'cd'.
# So I made an alias to 'cd' with the $PS1-changing-function
# If I ever find out a solution, uncomment the double-# lines
# # alias cd='change_dir_color_on_ps1'

# # function change_dir_color_on_ps1() {

# #		# All the lovely colors
# #		red=$(tput setaf 1)
# #		green=$(tput setaf 2)
# #		yellow=$(tput setaf 3)
# #		blue=$(tput setaf 4)
# #		purple=$(tput setaf 5)
# #		cyan=$(tput setaf 6)
# #		reset=$(tput sgr0)
# #		bold=$(tput bold)

# #		# user-defined
# #		COLOR_EMPTY=$red
# #		COLOR_NOT_EMPTY=$cyan

# #		# If we dont send any parameters, it'll not 'cd'
# #		# That's because I need to execute this function for the
# #		# first time, when the terminal starts, to check if the current
# #		# dir is empty.
# #		# Certainly there's another solution I'm missing
# #		if [ $# -ne 0 ]; then
# #			cd "$@"
# #			if [ $? -ne 0 ]; then
# #				return 1
# #			fi
# #		fi

# #		COUNT=`ls -la | wc -l`

# #		# Well, 3 because with 'ls -la' there's '.' '..' and the 'total' line
# #		if [ $COUNT -eq 3 ]; then
# #			IS_EMPTY=1
# #		else
# #			IS_EMPTY=0
# #		fi

# #		if [ $IS_EMPTY -eq 1 ]; then
# #			DIR_COLOR=$COLOR_EMPTY
# #		else
# #			DIR_COLOR=$COLOR_NOT_EMPTY
# #		fi

# #		# Example: 'user@current_folder $'
# #		PS1="\[$bold\]\[$blue\]\u@\[$DIR_COLOR\]\W\[$reset\] $ "
# # }

# Stuff will be played real smooth now
alias mplayer="mplayer -autosync 30 -nocache -framedrop"

# 'terminal player': play videos on console (depends on alias above and libcaca)
alias tplayer="mplayer -vo caca"

# Tired of typing this over and over
alias wi='wicd-curses'

# Avoid re-reading this file unless explicitly asked (by the alias 'resource')
fi

# To make rtorrent work with colors, I gotta reference the local install with
# a different term.
# Now it thinks I have 256 colors
alias rtorrent='TERM="xterm-256color" rtorrent'

# `acoc` is an awesome utility to print colored output
alias mount="acoc mount"
alias ping="acoc ping"
alias free="acoc free -m"
alias ps="acoc ps"
alias apt-get="acoc apt-get"
alias id="acoc id"
alias make="acoc make"
alias gcc="acoc gcc"
alias ldd="acoc ldd"
alias tcpdump="acoc tcpdump"
alias netstat="acoc netstat"
alias whereis="acoc whereis"
alias w="acoc w"
alias nmap="acoc nmap"
alias g++="acoc g++"
alias df="acoc df -h"			   # alias df="df -h"
alias apt-cache="acoc apt-cache"
alias diff='acoc diff'
alias sdcv='acoc sdcv' # great dict

# Starting the GNOME document viewer without spilling output everywhere
alias evince='evince &>/dev/null'

# Escape codes to change the tab title of the mrxvt terminal emulator
function mrxvt-title() { echo -ne "\e]62;$@\a"; }

# RVM needs to run on a login shell
alias use-rvm='source ~/.bash_profile'

# Emacs-related
# Force commandline emacs
alias emacs='emacs -nw'

# Debian packager
alias debuildsa='dpkg-buildpackage -sa -kB63CF56F'
alias uscan='uscan --verbose --report'

# to make acoc work, i need to redirect stderr to stdout
alias debuild='acoc debuild --lintian-opts -I --pedantic 2>&1'
alias lintian='acoc lintian'

alias mydate='date "+%d-%m-%y"'

# My hand's starting to hurt ):
# Need this to remind myself of the exercises
function hand() {
	echo 'Open and Close'
	echo 'Thumb Circles'
	echo 'Clench Hand'
	echo 'Tip Touch'
	echo 'Wrist Rotate'
	echo 'friggin use right hand to Alt'
}

alias makewin='make -f Makefile.windows'

# Arch linux!
# Won't reinstall packages
alias pacman='yaourt --needed'

# This makes screenfetching a lot easier
# (placing them with custom name on '~/screenshots'
alias scrot='scrot "screen-%F-%T.png" -e "mv $f ~/screenshots/ 2>/dev/null"'

# My Midnight Commander theme (`~/.local/share/mc/skins/`)
alias mc='mc -S kure-theme.ini'

# The MIPS simulator. Nice alias to pretend it's installed on my system.
alias mars='java -jar ~/local/mars4.1_custom.jar 2>/dev/null &'

# Asciidoc Website Builder
alias awb='awb -c=/home/kure/.config/awb/'

# Refreshes Awesome Window Manager's menu
alias awesome-menu-refresh='xdg_menu --format awesome > ~/.config/awesome/xdgmenu.lua'

# Safely removing USB drives
alias eject='sudo eject -v'

# Incredibly small emacs clone (A.K.A "nano killer").
# This switch disables creating those annoying files ending with '~'
alias mg='mg -n'

# Nice function that turns off caps-lock by commandline. Uses python's
# Taken from (explanation included):
# http://askubuntu.com/questions/80254/how-do-i-turn-off-caps-lock-the-lock-not-the-key-by-command-line
function capslock-off() {
	python -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'
}

# Just in case.
function capslock-on() {
	python -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(2)); X11.XCloseDisplay(display)'
}

# Just a reminder to look at `~/.inputrc`.
# Nice aliases there.

# Instead of these, using functions
#alias mo="udisksctl mount -b"
#alias umo="udisksctl unmount -b"

# Shortcut for mounting pendrives
# 'mo b1 pen' -> 'mount /dev/sdb1 /media/pen'
#
# If no arguments are sent, list all mountable drives
function mo() {
	if [ -z "$1" ]; then
		echo "Listing all mountable drives..."
		ls /dev/sd* -w 1
		return 0
	fi

	echo "Mounting /dev/sd$1..."
	udisksctl mount -b /dev/sd$1
}

# Shortcut for unmounting pendrives
function umo() {
	if [ -z "$1" ]; then
		echo "Listing all unmountable drivers..."
		mount | grep 'dev/sd' | cut -d ' ' -f1
		return 0
	fi
	echo "Unmounting /dev/sd$1..."
	udisksctl unmount -b /dev/sd$1
}

# Great lightweight browser
alias uzbl="uzbl-tabbed"
function isa() { cat ~/freebsd; }

# Locks screen with `xscreensaver`.
# It normally isn't started up automatically with my distro,
# so this is a chance to both initialize it and lock the
# screen.
function lock() {
	xscreensaver -no-splash &>/dev/null &
	xscreensaver-command -lock
}

# Colored and pretty tree
alias tree='tree -C -A'

# Simple date formatter in Ruby
alias rdate="ruby -r 'date' -e 'puts Date.today.strftime %q{%b %d, %Y}'"

# Showing previous/current/next month
alias cal="cal -3"
