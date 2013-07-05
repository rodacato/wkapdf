$:.unshift File.expand_path('lib', File.dirname(__FILE__))

require 'rubygems'
require 'debugger'
require 'require_all'

require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/assetpack'

require_all 'lib'

class App < Sinatra::Base
  register Sinatra::AssetPack, Sinatra::ConfigFile
  use Rack::CommonLogger, Rack::Protection

  set :root, File.dirname(__FILE__)

  enable :sessions, :logging, :dump_errors, :raise_errors, :show_exceptions, :static

  config_file '../config/config.yml'

  assets do
    serve '/js', from: '/app/js'
    js :application, [
      '/js/vendor/jquery.js',
      '/js/vendor/jquery.*.js',
      '/js/vendor/underscore.js',
      '/js/vendor/bootstrap.js',
      '/js/vendor/jquery.backstretch.min.js',
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

  get '/showcase' do
    @urls = [ "/generate/wkhtmltopdf?url=#{params['url']}",
              "/generate/pdfcrowd?url=#{params['url']}",
              "/generate/doc_raptor?url=#{params['url']}"
            ]
    erb :showcase
  end

  get '/generate/:provider' do
    filename = "#{settings.root}/tmp/#{SecureRandom.urlsafe_base64(10)}.pdf"
    provider = case params['provider']
                  when 'pdfcrowd'
                    Exporter::Strategies::Pdfcrowd.new
                  when 'wkhtmltopdf'
                    Exporter::Strategies::Wkhtmltopdf.new
                  when 'doc_raptor'
                    Exporter::Strategies::DocRaptor.new
                end
    exporter = Exporter::Pdf.new(provider)
    exporter.build(filename, params['url'], params['options'] || nil)
    send_file File.open(filename), :type => :pdf
  end

  get '/tester' do
    erb :tester
  end

  # Errors
  not_found do
    erb :'404'
  end

  error do
    erb :'500'
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
