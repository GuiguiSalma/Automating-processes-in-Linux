#!/bin/bash

# This checks if the number of arguments is correct for the user before starting the back up operations
# If the number of arguments is incorrect ( $# != 2) print error message and exit
if [[ $# != 2 ]]
then
  echo "backup.sh target_directory_name destination_directory_name"
  exit
fi

# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
  echo "Invalid directory path provided"
  exit
fi


targetDirectory=$1
destinationDirectory=$2


echo "targetDirectory is $targetDirectory"
echo "destinationDirectory is $destinationDirectory"

#you'll see it even in the etl scropt, it's good to save the currenttime/date in the filename
currentTS=$(date +%s)


backupFileName="backup-$currentTS.tar.gz"

# We're going to:
  # 1: Go into the target directory
  # 2: Create the backup file
  # 3: Move the backup file to the destination directory

# To make things easier,  define some useful variables...


origAbsPath=$(pwd)

cd $destinationDirectory
destAbsPath=$(pwd)

cd $origAbsPath
cd $targetDirectory

# so the backup file will run on the last modified files in the last 24hours
yesterdayTS=$(($currentTS - 24 * 60 * 60))

declare -a toBackup

for file in $(ls) 
do
  
  if ((`date -r $file +%s` > $yesterdayTS))
  then
    
    toBackup+=($file)
  fi
done


tar -czvf $backupFileName ${toBackup[@]}


mv $backupFileName $destAbsPath


