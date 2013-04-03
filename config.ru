require 'rubygems'
require 'sinatra'
require 'bundler'

root_dir = File.dirname(__FILE__)

Bundler.require
require File.join(root_dir + "/app.rb")

run App