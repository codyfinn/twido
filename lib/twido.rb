# Copyright 2012 Cody Finn
# This file is part of Twido.
#
# Twido is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Twido is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Twido.  If not, see <http://www.gnu.org/licenses/>.

require "twido/version"
require "twitter"
require "twido/authentication"
require "highline/import"
require "yaml"

module Twido
  # Public: authenticates the user using the authenticate method of the Authentication module
  # Returns a Twitter::Client
  # Examples
  #
  # self.authenticate
  #     # => Twitter::Client
  def self.authenticate
    @twitter_client = Twido::Authentication.authenticate
  end

  # Public: propts the user to set up thier account with the information needed to register thier app
  # Returns nil
  # Examples
  def self.setup
    messege=<<-MESSEGE
      Welcome! Before you can use Twido, you'll first need to register an
      application with Twitter. Just follow the steps below:
        1. Sign in to the Twitter Developer site and click
           "Create a new application".
        2. Complete the required fields and submit the form.
           Note: Your application must have a unique name.
           We recommend: "<your handle>/t".
        3. Go to the Settings tab of your application, and change the
           Access setting to "Read, Write and Access direct messages".
        4. Go to the Details tab to view the consumer key and secret,
           which you'll need to copy and paste below when prompted.
    MESSEGE

    user_info = {}

    puts messege
    user_info[:consumer_key] = ask("Enter consumer key: ") { |q| q.echo = true }
    user_info[:consumer_secret] = ask("Enter consumer secret: ") { |q| q.echo = true }
    user_info[:oauth_token] = ask("Enter Oauth token: ") { |q| q.echo = true }
    user_info[:oauth_token_secret] = ask("Enter Oauth token secret: ") { |q| q.echo = true}

    Authentication.write_credentials_to_config(user_info)
  end

  # Public: shows the user the top 10 most recent posts containing "#todo" asks if they completed any tasks if so then it runs them through the complete method
  # Returns an array of tweets, or a messege either confriming completion or confriming no comletion
  # Examples
  #
  #   self.list
  #     # => [0] task #todo
  #          [1] task 2 # todo
  #          Did you complete a task?:
  #           # => y
                # => TASK COMPLETED
  #   self.list
  #     # => [0] task #todo
  #          [1] task 2 # todo
  #          Did you complete a task?:
  #           # => n
  #             # => Have a good and productive day!
  #   self.list
  #     # => [0] task #todo
  #          [1] task 2 # todo
  #          Did you complete a task?:
  #           # => g
  #             # => TASK ERROR: ACTION NOT RECONIZED
  def self.list(tweets = self.build_list)
    tweets.each_with_index { |tweet, index| puts "[#{index}] #{tweet.text}" }
  end

  # Public: removes a task from the user's to do list by deleting the tweet and confirming
  # Returns a string stating if task was completed or not
  # Examples
  #
  #   self.complete
  #     # => [0] Task #todo
  #          [1] Task2 #todo
  #          Enter task ID:
  #           1
  #             Are you sure you completed this task?:
  #               y
  #                 TASK COMPLETED
  #   self.complete
  #     # => [0] Task #todo
  #          [1] Task2 #todo
  #          Enter task ID:
  #           0
  #             Are you sure you completed this task?:
  #               n
  #                 Have a good and productive day!
  def self.complete
    twitter_client = Authentication.authenticate
    tweets = self.build_list
    self.list
    complete_index = ask("Enter task ID: ")
    complete = Integer(complete_index)
    tweet_id = tweets[complete].id
    confirm = ask("Are you sure you completed this task?: ")
      case confirm.downcase.to_sym
      when :no, :n
        puts "Have a good and productive day!"
      when :yes, :y
    twitter_client.status_destroy(tweet_id)
    puts "TASK COMPLETED"
    end
  end

  # Public: adds a task to the user's todo list by tweeting a tweet that the user defines and automaticly adds the "#todo" to the end
  # Returns nil
  # Examples
  #
  #   self.task
  #     # => What do you have to do?:
  #       task
  def self.task
    twitter_client = Authentication.authenticate
    task = ask("What do you have to do?: ") + " #todo"
    twitter_client.update(task)
  end

  # Private: Gets a list of tweets with "#todo"
  # Retruns Array of tweets
  # Examples
  # self.build_list
  #   # => [tweet1, tweet2, ...]
  def self.build_list(count = 10)
    twitter_client = Authentication.authenticate
    user = twitter_client.user.screen_name
    twitter_client.search("#todo", count: count, from:user).statuses
  end
  
  # Public: Gets list of tweets with the hash tag #"group"_todo
  # Returns Array of tweets
  # Examples
  # self.group
  #   #=> [tweet1, tweet2,...]
  def self.group(count = 20)
    twitter_client = Authentication.authenticate
    group_name = ask("Enter group name: ") + "_todo"
    tweets = twitter_client.search(group_name, count: count).statuses
    tweets.each_with_index { |tweet, index| puts "[#{index}] #{tweet.text}" }
  end 
  
  # Public: removes a task from the specified group's to do list by deleting the tweet and confirming authorship
  # Returns a string stating if task was completed or not
  # Examples
  #
  #   self.group_complete
  #     # => [0] Task #todo
  #          [1] Task2 #todo
  #          Enter task ID:
  #           1
  #             Are you sure you completed this task?:
  #               y
  #                 TASK COMPLETED
  #   self.group_complete
  #     # => [0] Task #todo
  #          [1] Task2 #todo
  #          Enter task ID:
  #           0
  #             Are you sure you completed this task?:
  #               n
  #                 Have a good and productive day!
  def self.group_complete
    twitter_client = Authentication.authenticate
    tweets = self.group
    complete_index = ask("Enter task ID: ")
    complete = Integer(complete_index)
    tweet_id = tweets[complete].id
    author = twitter_client.status(tweet_id,{"trim_user" => true})
    user = twitter_client.user
    confirm = ask("Are you sure you completed this task?: ")
    case confirm.downcase.to_sym
    when :no, :n
      puts "Have a good and productive day!"
    when :yes, :y
    confirm = ask("Is this your tweet?: ")
    case confirm.downcase.to_sym
    when :yes, :y  
      twitter_client.status_destroy(tweet_id)
      puts "TASK COMPLETED"
    when :no, :n
        twitter_client.update(" Task completed please delete task", {"in_reply_to_status_id" => tweet_id})
      end
    end
  end
  
  # Public: adds a task to the specified group's todo list by tweeting a tweet that the user defines and automaticly adds the "#group_name_todo" to the end
  # Returns nil
  # Examples
  #
  #   self.group_task
  #     # => What do you have to do?:
  #       task
  def self.group_task
    twitter_client = Authentication.authenticate
    group_name = ask("Enter group name: ") + "_todo"
    task = ask("What do you have to do?: ") + " #" + group_name
    twitter_client.update(task)
  end
  
  # Public: Gives the user a list of commands that can be used with Twido
  # Returns nil
  # Examples
  #
  #   self.help
  #     # => To use Twido first type "twido setup" and follow the steps
  #   The following are commands:
      
  #   list, l: lists your personal todo list
      
  #   complete, c: lets you complete a given task
      
  #   task, t: lets you add a new task to your todo list
      
  #   group, g: lists a specified group's todo list
      
  #   group_complete, gc: lets you complete a group task or mark it as completed
      
  #   group_task: lests you add a new task to a specifed group's todo list
  # MESSAGE
 
  def self.help
    message = <<-MESSAGE
      To use Twido first type "twido setup" and follow the steps
      The following are commands:
      
      list, l: lists your personal todo list
      
      complete, c: lets you complete a given task
      
      task, t: lets you add a new task to your todo list
      
      group, g: lists a specified group's todo list
      
      group_complete, gc: lets you complete a group task or mark it as completed
      
      group_task: lests you add a new task to a specifed group's todo list
   MESSAGE
   
   puts message
 end 
    
    
end