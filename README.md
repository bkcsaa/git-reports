# GitHub Reports
This repository houses some ruby scripts for reporting on our GitHub organization.

Set the variable GITHUB_TOKEN to a valid developer token with permissions to view org private repositories.  Otherwise, only public repositories will be retuned

## Gem Dependencies
* octokit - GitHub API library

## Reports 
### contrib-stats 
Produce a report of active committers and repositories in the last X number of days.  Currently, the number of days is set by the *days* variable in the top of the script.

USAGE: contrib-stats.rb [-s] [-n] 

* -s : apply Snyk filter,
* -n : allow Nil authors and committers


#### Roadmap
* Select *days* from the command-line
* Move *snyk_list* to an external file and add a -f argument to supply an external filter file.