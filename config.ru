require 'rubygems'
require 'bundler'

::RACK_ENV = ENV['RACK_ENV'] || 'development'
Bundler.require(:default, RACK_ENV)

require "#{File.dirname(__FILE__)}/app"

run App
