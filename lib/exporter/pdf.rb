require 'benchmark'

module Exporter
  class Pdf
    attr_accessor :strategy, :benchmark

    def initialize(strategy = Strategies::DocRaptor.new)
      @strategy = strategy
    end

    def build(filename, html_or_page_url, options = nil)
      File.open(filename, 'w+b') do |f|
        @benchmark = Benchmark.measure {
          f.write @strategy.create(filename, html_or_page_url, options)
        }
      end
    end
  end
end
