module Exporter
  module Strategies
    module Exceptions
      class PDFCreationError < StandardError;
        def initialize(msg = "PDF Document couldn't be created")
          super
        end
      end
    end
  end
end
