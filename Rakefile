#!/usr/bin/env rake

require 'huginn_agent'

HuginnAgent.load_tasks(branch: 'master', remote: 'https://github.com/cantino/huginn.git')


#Rake.application.lookup('prepare').clear

task :soft_prepare do
  puts "prepare env"
  require 'huginn_agent/spec_runner'
  runner = HuginnAgent::SpecRunner.new
  #runner.clone
  #runner.reset
  runner.bundle
  runner.database
end

#task :default => [:prepare, :spec]

