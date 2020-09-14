#!/bin/bash

#////////////////////////////////////
# mikhmon-installer
#////////////////////////////////////

MULEH=$(cd $HOME)
ELF=$(echo -e)
COLOUR_RESET='\e[0m'
aCOLOUR=(
		'\e[1;33m'	# Yellow	|
		'\e[1m'		# Bold white	|
		'\e[1;32m'	# Green		|
		'\e[1;31m'      # Red		|

	)
YELLOW_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
GREEN_BULLET=" ${aCOLOUR[2]}		[+]	$COLOUR_RESET"
GREEN_WARN=" ${aCOLOUR[2]}            [!]  $COLOUR_RESET"
RED_WARN=" ${aCOLOUR[3]}            [!]     $COLOUR_RESET"


#check mikhmon
clonerepo() {
		$ELF $YELLOW_LINE
		$ELF $GREEN_BULLET "${aCOLOUR[2]}Checking mikhmon repository"
		$ELF $YELLOW_LINE

			if ls -l $HOME | grep mikhmonv3 ; then
				$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
			else
			        $ELF $RED_WARN "${aCOLOUR[2]}Repository not found"
				$ELF $RED_WARN "${aCOLOUR[2]}Cloning it"
				$MULEH ; git clone https://github.com/laksa19/mikhmonv3
				$ELF $GREEN_WARN "${aCOLOUR[2]}Clone done"
			fi
}

permission() {
		$ELF $YELLOW_LINE
                $ELF $GREEN_BULLET "${aCOLOUR[2]}Checking permission"
                $ELF $YELLOW_LINE

        		if ls -l $HOME/mikhmonv3 | grep "rwxr-xr-x" ; then
                		$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
        		else
                		$MULEH ; sudo chmod -R 755 mikhmonv3
        		fi

        	if ls -l $HOME/mikhmonv3 | grep "www-data" ; then
         		$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
       		else
           		$MULEH ; sudo chown -R www-data:www-data mikhmonv3
       		fi
}

#check images
images_armv7() {
		$ELF $YELLOW_LINE
                $ELF $GREEN_BULLET "${aCOLOUR[2]}Checking docker images"
                $ELF $YELLOW_LINE

			if docker images | grep "davidsal/lamp-armv7" ; then
        			$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
			else
        			docker pull davidsal/lamp-armv7:latest
			fi
}

#kickoff
kickoff() {
		docker run -d --tty -p 8080:80 -p 8081:3306 -v ${HOME}/mikhmonv3:/var/www/html --name mikhmonv3 davidsal/lamp-armv7
}

run_armv7() {
		$ELF $YELLOW_LINE
                $ELF $GREEN_BULLET "${aCOLOUR[2]}Running mikhmon"
                $ELF $YELLOW_LINE

				kickoff
				if docker ps -a | grep 'mikhmonv3' | grep -v 'Exited' ; then
					$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
				else
					$ELF $RED_WARN "${aCOLOUR[2]}Retrying  [1]"
					kickoff
				else
					$ELF $RED_WARN "${aCOLOUR[2]}Retrying  [2]"
                                        kickoff
				else
					$ELF $RED_WARN "${aCOLOUR[2]}Can't running"
}


#go
is_docker_running() {
sudo systemctl is-active docker | grep active
}

is_docker_enabled() {
sudo systemctl is-enabled docker | grep disabled
}

HOST_ARCH=$(uname -m)
if [ "${HOST_ARCH}" != "armv7l" ]; then
  $ELF $RED_WARN "${aCOLOUR[2]}This script is only intended to run on ARM 32 bit v7 devices."
  exit 1
fi

check_docker() {
   if [[ $(id -u) == "1000" ]] ; then
        $ELF $RED_WARN "${aCOLOUR[2]}Non root detected"
	if groups | grep docker ;  then
		$ELF $GREEN_WARN "${aCOLOUR[2]}OK"
	else
		$ELF $RED_WARN "${aCOLOUR[2]}Docker not in the groups"
		SOPO=$(env | grep -i user | cut -c 6-30)
		sudo usermod -aG $SOPO
			echo -e "\033[0;33m After change groups need relogin and after login run this script to do next steps"
      			read -p "Relogin now ? [Y/y/N/n]" -n 1 -r
      			echo -e "\033[0;37m"
 				if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
					exit 2
				else
					exit 7
				fi
   fi
}

    $ELF $YELLOW_LINE
    $ELF $GREEN_BULLET "${aCOLOUR[2]}Checking docker"
    $ELF $YELLOW_LINE

	if is_docker_running ; then
		$ELF $GREEN_WARN "${aCOLOUR[2]}Docker OK"
			if is_docker_enabled ;  then
				sudo systemctl enable docker
			fi
				check_docker

					$ELF $YELLOW_LINE
    					$ELF $GREEN_BULLET "${aCOLOUR[2]}Go"
					$ELF $YELLOW_LINE

						clonerepo ; permission ; images_armv7 ; run_armv7
	else
		$ELF $RED_WARN "${aCOLOUR[2]}Please install docker"
	fi
