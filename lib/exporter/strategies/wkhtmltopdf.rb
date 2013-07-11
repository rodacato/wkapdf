require 'httparty'

module Exporter
  module Strategies
    class Wkhtmltopdf

      attr_accessor :command

      def initialize(*opts)
        @command = opts.first[:command]
      end

      def create(filename, html_or_page_url, options = nil)
        response = `#{command} #{options.gsub(/\r\n/, '') if options} #{html_or_page_url} #{filename}`
        File.open(filename).read
      end
    end
  end
end

