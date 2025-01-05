echo "Commit Hash,Authored Date,Author Name,Author Email,Comment Subject,Files Changed,Lines Added,Lines Deleted" > gitlogs.csv
$gitlogs = git log --since='2024-03-21' --pretty=format:'%x02%x22%h%x22%x2C%x22%ad%x22%x2C%x22%an%x22%x2C%x22%ae%x22%x2C%x22%s%x22%x2C' --date=iso-strict --shortstat
$gitlogs -Split [Environment]::NewLine -Join '' -Replace '\x02',[Environment]::NewLine >> gitlogs.csv