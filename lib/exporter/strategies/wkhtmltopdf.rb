require 'httparty'

module Exporter
  module Strategies
    class Wkhtmltopdf

      def create(filename, html_or_page_url, options = nil)
        response = `wkhtmltopdf11 #{options.gsub(/\r\n/, '') if options} #{html_or_page_url} #{filename}`
        File.open(filename).read
      end
    end
  end
end

