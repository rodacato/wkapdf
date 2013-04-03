require 'httparty'

module Exporter
  module PdfUtils
    def extract_html(url)
      HTTParty.get(url).to_s
    end

    def uri?(string)
      uri = URI.parse(string)
      ['http','https'].include? uri.scheme
    rescue URI::BadURIError, URI::InvalidURIError
      false
    end
  end
end
