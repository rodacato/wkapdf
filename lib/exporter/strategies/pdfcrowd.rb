require 'pdfcrowd'
require 'tempfile'

module Exporter
  module Strategies
    class Pdfcrowd
      include Exporter::PdfUtils

      def create(filename, html_or_page_url)
        @client = ::Pdfcrowd::Client.new(settings.exporter.pdfcrowd.username, settings.exporter.pdfcrowd.api_key)
        build_document(html_or_page_url)
      end

      private
      def build_document(html_or_page_url)
        begin
          if uri?(html_or_page_url)
            response = @client.convertURI(html_or_page_url)
          else
            tmpfile = Tempfile.new(SecureRandom.base64(10)) {|f| @client.convertHtml(html_or_page_url, f)}
            tmpfile.rewind
            response = tmpfile.read
            tmpfile.close
            tmpfile.unlink
          end
          response
        rescue ::Pdfcrowd::Error => why
          raise Exporter::Strategies::Exceptions::PDFCreationError, why
        end
      end

    end
  end
end
