require 'httparty'

module Exporter
  module Strategies
    class DocRaptor
      include Exporter::PdfUtils
      include HTTParty

      base_uri "https://docraptor.com"

      def create(filename, html_or_page_url)
        html = uri?(html_or_page_url) ? extract_html(html_or_page_url) : html_or_page_url

        @options = {
          :body => {
            :doc => {
              :document_content => html,
              :name             => filename,
              :document_type    => "pdf",
              :test             => true,
              :javascript       => true,
              :strict           => 'none'
            }
          },
          :basic_auth => {
            :username => APP_CONF['exporter']['docraptor']['api_key']
          }
        }
        build_document
      end

      private
      def build_document
        response = get_document
        if response.code != 200 && response.to_s.match(/error/)
          raise Exporter::Strategies::Exceptions::PDFCreationError, response.to_s.scan(/error\"=>(\[.*\])/).flatten[0]
        end
        response
      end

      def get_document
        self.class.post("/docs", @options)
      end

    end
  end
end
