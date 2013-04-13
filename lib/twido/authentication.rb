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

module Twido
  module Authentication
    USER_CONFIG_PATH = File.expand_path('~/.twido.conf')
    
    # Public: Checks to see if the config file exists on the user's home folder.
    # Returns true or false
    # Examples
    # 
    #   self.config_exists?
    #     #=> true
    #     
    #   self.config_exists?
    #     #=> false
    def self.config_exists?
      File.exist?(USER_CONFIG_PATH)
    end
    
    # Public: Writes the user's twitter login credentials to the config file on the user's home folder.
    # Returns nil
    # credentials - The user's twitter log in credentials.
    # Examples 
    #
    #   credentials = {consumer_key:'23459878923'...}
    #     self.write_credentials_to_config(credentials)
    #       #=> nil
    def self.write_credentials_to_config(credentials)
      File.open(USER_CONFIG_PATH, 'w') { |file| file.puts(credentials.to_yaml) }
    end
    
    # Public: Loads the user's twitter credentials from the config file on the user's home folder.
    # Returns a hash filled with the credentials.
    # Examples
    # 
    #   self.load_credentials()
    #     # => {consumer_key:'23459878923'...}
    
    def self.load_credentials()
      hash = YAML.load_file(USER_CONFIG_PATH)
    end
    
    # Public: Creates a new Twitter::Client with the users credentials
    # Returns a Twitter::Client
    # Examples
    # 
    #   self.authenticate()
    #     # => Twitter::Client
    
    def self.authenticate   
      if self.config_exists?
        if twitter_client = Twitter::Client.new(self.load_credentials())
          twitter_client
        else
          abort 'ERROR: Error authenticating your account, run setup to reconfigure'
        end
      else
        abort 'ERROR: You have not setup twido yet, run twido setup to configure it.'
      end
    end
    
    # Public: makes a task done by deleting the tweet it came from
    # Returns nil
    # Examples 
    # 
    #   self.complete_task(tweet)
    #     => nil
    def self.complete_task(tweet)
      Twitter::Client.new.status_destroy(id)
    end
  end
end