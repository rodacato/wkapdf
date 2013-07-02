$:.unshift File.expand_path('lib', File.dirname(__FILE__))

require 'rubygems'
require 'debugger'

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/contrib'
require 'sinatra/assetpack'
require 'compass'
require 'sinatra/support'

require 'exporter/pdf'
require 'exporter/pdf_utils'
require 'exporter/strategies/exceptions'
require 'exporter/strategies/doc_raptor'
require 'exporter/strategies/pdfcrowd'
require 'exporter/strategies/wkhtmltopdf'

class App < Sinatra::Base
  use Rack::CommonLogger, Rack::Protection

  set :root, File.dirname(__FILE__)
  set :protection, :except => [:frame_options]

  register Sinatra::AssetPack, Sinatra::ConfigFile, Sinatra::CompassSupport

  configure(:production, :development) do
    enable :logging, :dump_errors, :raise_errors, :show_exceptions, :static
  end

  config_file '../config/config.yml'

  assets do
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

  get '/showcase' do
    @original = "/generate/wkhtmltopdf.pdf?url=#{params['url']}"
    @urls = [ "/generate/pdfcrowd.pdf?url=#{params['url']}",
              "/generate/doc_raptor.pdf?url=#{params['url']}"
            ]
    erb :showcase
  end

  get '/generate/:provider.pdf' do
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
    exporter.build(filename, params['url'])
    send_file File.open(filename), :type => 'application/pdf'
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
