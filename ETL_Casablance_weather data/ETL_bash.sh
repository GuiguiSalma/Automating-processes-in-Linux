#!/bin/bash
#Creating the file where the history of the daily weather data i scraped will be
touch rx_poc.log

#having a header schema for our "table"
echo -e "year\tmonth\tday\thour\tobs_tmp\tfc_temp">rx_poc.log

touch rx_poc.sh #it's this bash script, just create any file to build your ETL pipeline then run it

#Downloading  today’s weather report from wttr.in
#first we gotta create the filename for today’s wttr.in weather report
weather_report=raw_data_$(date +%Y%m%d) #it's the same as creating a variable today=$(date +%Y%m%d) and then the filename variable

#Downloading the wttr.in weather report for Casablanca and saving it
curl wttr.in/$city --output $weather_report

#now we'll strat extracting only the data we need and putting it in our table/file.log

#extracting the temperature data and putting it in a .txt file
grep °C $weather_report > temperatures.txt #grep is very useful linux, it searchs for lines containing the string you want

#extracting tha temp we want
#if you analyse the data you extracted you'll find that today's temp is in first line, tomorrow's is in 3, it's up to you to extract it the way you want
obs_tmp=$(head -1 temperatures.txt | tr -s " " | xargs | rev | cut -d " " -f2 | rev)

#storing the timezone into variables
hour=$(TZ='Morocco/Casablanca' date -u +%H) 
day=$(TZ='Morocco/Casablanca' date -u +%d) 
month=$(TZ='Morocco/Casablanca' date +%m)
year=$(TZ='Morocco/Casablanca' date +%Y)

#we storing our data in variables, now we append them to our table
record=$(echo -e "$year\t$month\t$day\t$hour\t$obs_tmp\t$fc_temp")
echo $record>>rx_poc.log

#scheduling the bash script to run every day at noon
#first we gotta check for the time difference between the system’s default time zone and UTC, since we're using the GMT system now in Morocco i don't need to know the difference.
#creating the cron job
crontab -e
0 0 * * * /home/project/rx_poc.sh #at midnight

