require 'hypdf'
require 'tempfile'

module Exporter
  module Strategies
    class Hypdf
      include Exporter::PdfUtils

      def create(filename, html_or_page_url, options = nil)
        filename = filename
        content = extract_html(html_or_page_url)
        build_document(filename, content)
      end

      private
      def build_document(filename, content)
        begin
          client = ::HyPDF.new(content, {:test => true})
          client.get
        rescue ::Pdfcrowd::Error => why
          raise Exporter::Strategies::Exceptions::PDFCreationError, why
        end
      end

    end
  end
end

