$:.unshift File.expand_path('../../../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack

  assets do

    #js_compression :closure
    js_compression :uglify

    serve '/js', from: '/app/js'
    js :application, [
      '/js/vendor/jquery.js',
      '/js/vendor/jquery.*.js',
      '/js/vendor/underscore.js',
      '/js/vendor/bootstrap.js',
      '/js/app.js'
    ]

    css_compression :sass

    serve '/css', from: '/app/css'
    css :application, [
      '/css/bootstrap/bootstrap.css',
      '/css/bootstrap/bootstrap-responsive.css',
      '/css/app.css'
    ]

    prebuild true
  end

  # Routes

  get '/' do
    erb :index
  end

  # Errors

  not_found do
    erb :'404'
  end

  error do
    erb :'500'
  end

  # Redirects

  get '/twitter' do
    redirect 'http://twitter.com'
  end

  # Partials

  helpers do
    def render_partial(template, args = {})
      template_array = template.to_s.split('/')
      template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
      erb(template.to_sym, :locals => args, :layout => false)
    end
  end

end

if __FILE__ == $0
  App.run!
end