#!/bin/ruby

## Output a list of members of an organization 

# Personal access token with `read:org` and `repo` access
# Created via https://github.com/settings/tokens/new


# grab any environment variables
access_token = ENV['GITHUB_TOKEN']  # needed for querying private repos in an org
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]


# Name of organization you'd like to generate the report for
org_name = "aaa-ncnu-ie"


# Init an authenticated client
# See http://octokit.github.io/ for .net and other languages
require 'octokit'
# client = Octokit::Client.new :access_token => access_token, :per_page => 100, :auto_paginate => true
client = Octokit::Client.new :access_token => access_token, :per_page => 100, :auto_paginate => true

client.auto_paginate=true   # enable auto pagination of results


class Committer
  def initialize(name, email)
      @name = name
      @email = email
      @count = 0
  end
end

def get_name(name)
 
  if name.nil? || name.length < 1 

    return "! NAME NOT DEFINED !"
  else
    return name

  end
end




puts "# GitHub Organization Report\n\n"


puts "********** Members **********"
# members = client.organization_members(org_name)
members = client.org_members(org_name)

puts "Members: #{members.count}\n\n"

printf("%s,%s,%s\n","Login","Name","Type")
members.each { |member|

  name_string = get_name(client.user(member.login).name)
  printf("%s,%s,%s\n",member.login,name_string,member.type)
}

puts "\n********** Outside Collaborators **********"
outside_collaborators = client.outside_collaborators(org_name)

puts "Outside Collaborators: #{outside_collaborators.count}\n\n"

printf("%s,%s,%s\n","Login","Name","Type")
outside_collaborators.each { |collaborator|

  name_string = get_name(client.user(collaborator.login).name)
  #puts collaborator.login + "\t\t\t #{name_string} ( Type: " + collaborator.type + ")\n" 
  printf("%s,%s,%s\n",collaborator.login,name_string,collaborator.type)

}




