require 'pdfcrowd'
require 'tempfile'
require 'open-uri'

module Exporter
  module Strategies
    class Pdfcrowd
      include Exporter::PdfUtils

      def create(filename, html_or_page_url, options = nil)
        @client = ::Pdfcrowd::Client.new('wakalord', '91004a27978dd61416da547373f447b0')
        #build_document(html_or_page_url)

        # For test proporses
        build_document_online(filename, html_or_page_url)
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

      def build_document_online(filename, html_or_page_url)
        document = HTTParty.post('https://pdfcrowd.com/form/json/convert/uri/', :body => {:src => html_or_page_url, :conversion_source => 'uri'})
        response = JSON.parse(document.body)
        url = "http://pdfcrowd.com#{response['uri']}"

        cmd = "wget -c '#{url}' -O '#{filename}'"
        system(cmd)
        File.open(filename).read
      end


    end
  end
end


# uri = URI('http://example.com/large_file')
#
# Net::HTTP.start(uri.host, uri.port) do |http|
#   request = Net::HTTP::Get.new uri.request_uri
#
#   http.request request do |response|
#     open 'large_file', 'w' do |io|
#       response.read_body do |chunk|
#         io.write chunk
#       end
#     end
#   end
# end

#        tmpfile = Tempfile.new(SecureRandom.base64(10)) do |f|
#          f << HTTParty.get(filename)
#        end
#        tmpfile.rewind
#        response = tmpfile.read
#        tmpfile.close
#        tmpfile.unlink
#        response
#      end


