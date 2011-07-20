# encoding: utf-8

require "rubygems"
require "bundler/setup"
require "octokit"

username = ARGV.shift
max_repos = (ARGV.shift || 10).to_i

unless username
  $stderr.puts "You must provide a username"
  exit(-1)
end

begin
  puts "Connecting..."
  following = Octokit.following(username)
  puts "#{username} is following #{following.size} users..."
  
  puts "Creating blacklist..."
  blacklist = Hash[Octokit.watched(username).map do |repo|
    [repo.owner + "/" + repo.name, true]
  end]
  
  puts "Looking for interesting repos..."
  to_watch = Hash.new(0)
  following.each do |user|
    Octokit.watched(user).each do |repo|
      fullname = repo.owner + "/" + repo.name
      unless blacklist[fullname]
        to_watch[fullname] = to_watch[fullname] + 1;
      end
    end
  end
  
  output = to_watch.map {|k, v| [k, v]}.sort {|b, a| a[1] <=> b[1]}[0...max_repos]
  puts "Interesting repos:"
  output.each do |name, points|
    puts "#{name} (#{points} points)"
  end
rescue Octokit::Error => error
  $stderr.puts error.to_s
end