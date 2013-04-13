# -*- encoding: utf-8 -*-

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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twido/version'

Gem::Specification.new do |gem|
  gem.name          = "twido"
  gem.version       = Twido::VERSION
  gem.authors       = ["Cody Finn"]
  gem.email         = ["finnmann13@gmail.com"]
  gem.description   = %q{A command line tool that can update and manage todo list on twitter.}
  gem.summary       = %q{Twitter backed CLI to do list.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency('rdoc')
  gem.add_development_dependency('aruba')
  gem.add_development_dependency('rake', '~> 0.9.2')
  gem.add_dependency('methadone', '~> 1.2.3')
  gem.add_dependency('twitter', '~> 4.4.1')
  gem.add_dependency('highline', '~> 1.6.15')
end
