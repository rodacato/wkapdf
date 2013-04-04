$:.unshift File.expand_path('lib', File.dirname(__FILE__))

require 'rubygems'
require 'debugger' if self.class.development?

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/contrib'
require 'sinatra/assetpack'

require 'exporter/pdf'
require 'exporter/pdf_utils'
require 'exporter/strategies/exceptions'
require 'exporter/strategies/doc_raptor'
require 'exporter/strategies/pdfcrowd'
require 'exporter/strategies/wkhtmltopdf'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack
  register Sinatra::ConfigFile

  use Rack::CommonLogger

  configure(:production, :development) do
    enable :logging, :dump_errors, :raise_errors, :show_exceptions, :static
  end

  config_file '../config/config.yml'

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

  before do
    logger.info params
  end

  # Routes
  get '/' do
    erb :index
  end

  get '/extract' do
    provider = case params['provider']
                  when 'pdfcrowd'
                    Exporter::Strategies::Pdfcrowd.new
                  when 'wkhtmltopdf'
                    Exporter::Strategies::Wkhtmltopdf.new
                  else 'doc_raptor'
                    Exporter::Strategies::DocRaptor.new
                end
    exporter = Exporter::Pdf.new(provider)
    exporter.build("#{SecureRandom.urlsafe_base64(10)}.pdf}", params['url'])

    erb :index
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
