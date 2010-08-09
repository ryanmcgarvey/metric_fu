require 'enumerator'
require 'date'
require 'csv'

module MetricFu
  class Perf < Generator


    class ScoreItem
      attr_accessor :score, :time
      def initialize(score,time)
        @score = score
        @time = time
      end
    end

    def emit
      `RAILS_ENV=#{MetricFu.perf[:environment]} rake test:benchmark`
    end

    def analyze
      @scores = {}
      metric_files = Dir["#{metric_directory}/*wall_time.csv"]
      metric_files.each do |metric_file|
        File.open("#{MetricFu.perf[:output_directory]}/#{metric_file}") do |in_file|
          @scores[metric_file] = process_wall_time_file(in_file.read)          
        end
      end
      @scores
    end

    def to_h
      {:perf => @scores}
    end

    def process_wall_time_file(csv_content, metric_file = '')
      scores = []
      CSV.parse(csv_content).each do |row|
        begin
          scores.push(parse_array_into_score_item(row))
        rescue ArgumentError, TypeError => e
          next
        end
      end
      scores
    end

    def parse_array_into_score_item(row)
      score = Float(row[0])
      time = DateTime.parse(row[1])

      ScoreItem.new(score,time)
    end

  end
end