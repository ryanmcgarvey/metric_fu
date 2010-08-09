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


    def self.metrics_directory
      #this needs to be replaced with something more generic and reasonable, obviously
      "/home/e3/dev/webTAC/tmp/performance"
    end

    def emit
      clean_scratch_directory
      run_performance_tests
    end

    def parse_array_into_score_item(row)
      score = Float(row[0])
      time = DateTime.parse(row[1])

      ScoreItem.new(score,time)
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

    def analyze
      @scores = {}
      metric_files = Dir["#{MetricFu::Perf.metrics_directory}/*wall_time.csv"]
      metric_files.each do |metric_file|
        File.open("#{MetricFu::Perf.metrics_directory}/#{metric_file}") do |in_file|
          process_wall_time_file(in_file.read)
        end
      end
      @scores
    end

    def to_h

    end

    private

    def clean_scratch_directory
      FileUtils.rm_rf(MetricFu::Perf.metric_directory, :verbose => false) if File.directory?(MetricFu::Perf.metric_directory)
      Dir.mkdir(MetricFu::Perf.metric_directory)
    end

    def run_performance_tests
      output = ">> #{MetricFu::Perf.metric_directory}/perf.txt"
      `RAILS_ENV=#{MetricFu.perf[:environment]} rake test:benchmark #{output}`

    end


  end
end