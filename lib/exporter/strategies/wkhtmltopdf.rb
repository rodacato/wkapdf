require 'httparty'

module Exporter
  module Strategies
    class Wkhtmltopdf

      def create(filename, html_or_page_url)
        response = `wkhtmltopdf #{html_or_page_url} #{filename}`
        File.open(filename).read
      end
    end
  end
end

