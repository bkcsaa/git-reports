#!/bin/ruby

## Output contributor statistics fro the organization

# Personal access token with `read:org` and `repo` access
# Created via https://github.com/settings/tokens/new


# grab any environment variables
access_token = ENV['GITHUB_TOKEN']  # needed for querying private repos in an org
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]

snyk = 's'
includeNil = 'n'
# puts args
# if args.key?(snyk)
#   puts "Snyk"
# end

# Name of organization you'd like to generate the report for
org_name = "aaa-ncnu-ie"

# List of Snyk managed repositories.  Activate with -s command-line argument if only interested in Snyk repos
snyk_list = [
            "CDS-Mobile-Controller",
            "Quote-2.0",
            "aaaie-cheese-nips",
            "b2b-portal",
            "cheese-board",
            "claims-rideshare",
            "b2b-custom-elements",
            "ds-cds-direct-access",
            "ds-cds-iportal",
            "ds-front-end-one-ui",
            "ds-static-assets",
            "insurance-portal-jcl",
            "mypolicy-jcl",
            "quote-2.0-worker",
            "spring-da-portal"
          ]


# Init an authenticated client
# See http://octokit.github.io/ for .net and other languages
require 'octokit'
# client = Octokit::Client.new :access_token => access_token, :per_page => 100, :auto_paginate => true
client = Octokit::Client.new :access_token => access_token, :per_page => 100, :auto_paginate => true


class Committer
  def initialize(name, email)
      @name = name
      @email = email
      @count = 0
  end
end

class ContributorStat 

  attr_reader :count

  def initialize(reponame, last_commit)
    @reponame=reponame
    @last_commit=last_commit
    # count of committers
    @count=0
    @committer_list = Array.new
  end

  def push(committer) 
    @committer_list.push(committer)
  end

  def in(committer)
    return @committer_list.include?(committer)
  end

  # Increment the committers count
  def increment
    @count += 1
  end

end


# days for time window
days = 360 

# Get the current time
# Using Time class seconds for the date window
date_window = Time.now - (days * 24 * 3600)

commits_since_date = date_window.strftime("%Y-%m-%d")

contributed_repos = Array.new
# maintain a list of unique committers
# TODO: change to a class from a simple list of GitHub logon_id strings
unique_committers = Array.new

puts "# GitHub Contributors Report\n"
puts "# #{days} day window selected, Commits since #{commits_since_date}"

args.key?(snyk) ? (puts "# Snyk filter selected") : ("# All repositories")

# Get a list of the organization repositories
puts "\n## Repositories accessed in last #{days} days\n"
repositories = client.organization_repositories(org_name)

# Iterate through each repository
repositories.each { |repository| 
  
  # only snyk repos if -s on command-line and repository name is in the snyk_list case-insensitive compare
  # snyk_repos = args.key?(snyk) && snyk_list.include?(repository.name) 
  snyk_repos = args.key?(snyk) && snyk_list.any?{ |sname| sname.casecmp(repository.name) == 0} 
  # all_repos if -s is not provided on the command-line
  all_repos = !args.key?(snyk) 
  
    # check if an active (commit) repository in the last 90 days and filter by snyk list if -s selected 
    if (repository.pushed_at > date_window) && (all_repos || snyk_repos)

      # add the repository to the list
      active_repo = ContributorStat.new(repository.name,repository.pushed_at)
      puts "\n\t## Repo Name: #{repository.name}, last pushed: #{repository.pushed_at}, private: #{repository.private}"

      puts "\n\t### Committers days"
      commits = client.commits_since(repository.full_name,commits_since_date)
      commits.each { |commit|
        if !commit.author.nil?
          puts "\t\tAuthor: #{commit.author.login}, Committer: #{commit.author.login}, Commit Author Email: #{commit.commit.author.email}, Commit Date: #{commit.commit.author.date}"
          if !active_repo.in(commit.author.login)
            active_repo.push(commit.author.login)
            active_repo.increment
            puts("\t\t#### add new committer #{commit.author.login} to list")
          end
          if !unique_committers.include?(commit.author.login)
            puts("\t\t#### unique committer #{commit.author.login} found")
            unique_committers.push(commit.author.login)
            # Increment the count of committers
            
          end
        else
          
          nilName = "NIL-#{commit.commit.author.email}"
          puts "\t\tNIL Found, #{nilName}"
          active_repo.push(nilName)

          # include Nil committers in the count of unique users
          if args.key?(includeNil) && !unique_committers.include?(nilName)
            puts("\t\t#### unique committer #{nilName} found")
            unique_committers.push(nilName)
          end
        end      
      }
      contributed_repos.push(active_repo)
      puts "\n\t### Contributors Count: #{active_repo.count}"
    end
  
}

puts "\n# SUMMARY"
puts "###########"

args.key?(snyk) ? (puts "\n# Filtered Snyk Repositories: #{snyk_list.count}, repos: #{snyk_list}") : ()
puts "\n# Number of repositories committed to in last #{days} days: #{contributed_repos.count}"

puts "\n# Number of unique committers in the last #{days} days: #{unique_committers.count}"

puts "\n# List of unique committers"
unique_committers.sort.each { |committer| puts("\t#{committer}") }
