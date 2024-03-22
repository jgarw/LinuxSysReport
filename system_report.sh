#!/bin/bash

#Student Name: Joseph Garwood
#Student Number: 041085246
#Course: CST8102 Section 351
#System_Report.sh
#Date: March 22 2024

clear

#create a function to display general system information
#Joseph Garwood 041085246
#March 22 2024
generalInfo(){

	#display current date and time to console at beginning of report
	echo "Report date & time: $(date)"
	echo

	#get computer hostname
	host=$(hostname)
	echo "Hostname: $host"

	#get computer OS
	os=$(uname -s)
	echo "Operating System: $os" 

	#get computer kernel
	kernel=$(uname -r)
	echo "Kernel Version: $kernel" 

	#get CPU model name
	echo "CPU Information: "
	lscpu | grep 'Model name'
	echo

	#display memory usage
	echo "Memory Usage: "
	checkMemory
	echo

	#display disk usage
	echo "Disk Usage Information:"
	checkDisk
	echo

	#display CPU Load average
	checkCPU
	echo
	
	#check that usage and loads are acceptable for memory, CPU and disk
	checkLoads

	echo
}

#a function to check the loads/usage of various components
#Joseph Garwood 041085246
#March 22 2024
checkLoads(){
	
	#create a threshold variable for comparing component loads to
	cpuThreshold=80
	memThreshold=50
	diskThreshold=70
	
	#calculate the percentage of memory used by using totalMemory and freeMemory
	memPercent=$(( (( $totalMem - $freeMem )) * 100 / $totalMem ))

	#check cpu load
	if (( $(echo "$cpuLoad > $cpuThreshold" | bc -l) )); then
                 echo "FAIL: CPU load is too high ($cpuLoad%)"
         else
                 echo "SUCCESS: CPU load is at acceptable level($cpuLoad%)"
         fi
	
	#check memory usage
	if (( $(echo "$memPercent > $memThreshold") )); then
		echo "FAIL: Memory usage is too high($memPercent%)"
	else
		echo "SUCCESS: Memory usage is at acceptable level($memPercent%)"
	fi

	#check disk load
	if (( $(echo "$diskLoad > $diskThreshold") )); then
                 echo "FAIL: Disk usage is too high($diskLoad%)"
         else
                 echo "SUCCESS: Disk usage is at acceptable level($diskLoad%)"
         fi

} 

#create a function to check the memory load
#Joseph Garwood 041085246
#March 22 2024
checkMemory(){
	
	#get the total memory from free command
	totalMem=$(free -m | sed -n '2p' | awk '{print $2}')
	echo "Total Memory: $totalMem MB"
	
	#get the total free memory from free command
	freeMem=$(free -m | sed -n '2p' | awk '{print $4}')
	echo "Free Memory: $freeMem MB"
}

#create a function to check the current CPU load.
#Joseph Garwood 041085246
#March 22 2024
checkCPU(){
	
	#display CPU Load average
         echo "CPU Load information: "
         cpuLoad=$(uptime | cut -d ' ' -f 12 | tr -d ',')
	
	#convert cpu load from decimal to percentage
	 cpuLoad=$(echo "$cpuLoad * 100" | bc -l )
         echo "Load Average: $cpuLoad%"
}

#create a function to check current disk load
#Joseph Garwood 041085246
#March 22 2024
checkDisk(){
	
	#use 'sed' and 'awk' commands to get total disk size
	diskSize=$(df -h | sed -n '3p' | awk '{print $2}')
	
	#use 'sed' and 'awk' commands to get disk space used
	diskUsed=$(df -h | sed -n '3p' | awk '{print $3}')

	#use 'sed' and 'awk' commands to get free disk space
	diskFree=$(df -h | sed -n '3p' | awk '{print $4}')
	
	#use 'sed' , 'cut' and 'awk' commands to get disk usage percent.
	diskLoad=$(df -h | sed -n '3p' | awk '{print $5}' | cut -d '%' -f 1)
	
	echo "Total: $diskSize Used: $diskUsed Free: $diskFree"
}

#create a log file and archive it into a tar folder
#Joseph Garwood 041085246
#March 22 2024
archive(){
	
	#check if system_report.log file already exists
	if [ -e "system_report.log" ]; then
                 echo "Log file already exists!"

		#ask user if they want to overwrite an existing log file
		read -p "Do you want to overwrite the existing log file?	(yY/nN)" owAnswer
		if [[ $owAnswer = y || $owAnswer = Y ]]; then
			#delete existing log file
			rm -r system_report.log
			#create a new log file
			touch system_report.log
			
			#run generalInfo report function
	                 generalInfo

	                 #attach generalInfo report output to log file
	                 generalInfo > system_report.log
	  
	                 #send log file to tar folder
	                 tar -czf system_report.tar.gz system_report.log
	                 echo "Archive created successfully."
	        else
			echo "Exiting script..."
			sleep 1
			exit 0
		fi

         else
                 echo "Log file does not exist or is empty. Generating a new report before creating archive..."
                 #create log file 
		touch system_report.log
	
		#run generalInfo report function
		generalInfo
		
		#attach generalInfo report output to log file
		generalInfo > system_report.log

		#send log file to tar folder
		tar -czf system_report.tar.gz system_report.log
		echo "Archive created successfully."
	fi
}

#main script that will prompt for user input.
while true; do
	echo "System Monitoring and Reporting"
	echo "+++++++++++++++++++++++++++++++++++"
	echo "1. Generate System Report"
	echo "2. Create Archive"
	echo "3. Exit"
	echo "+++++++++++++++++++++++++++++++++++"
	echo "Enter your choice: "
	read option

	case $option in
		1) 
		 generalInfo
		;;
		
		2)
		 archive
		;;

		3) 
		 echo "Exiting script..."
		 sleep 2
		 exit 0
		;;

		*)
		 echo "Invalid option! Select another option."

	esac
done