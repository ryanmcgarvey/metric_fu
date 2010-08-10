require 'enumerator'
require 'date'
require 'csv'

module MetricFu
  class Perf < Generator

    def emit
      `rake RAILS_ENV=#{MetricFu.perf[:environment]} test:benchmark`
    end

    def analyze
      @scores = {}
      metric_files = Dir["#{MetricFu.perf[:output_directory]}/*wall_time.csv"]
      metric_files.each do |metric_file|
        File.open(metric_file) do |in_file|
          file_title = File.basename(metric_file, ".csv")
          begin
            @scores[file_title] = process_wall_time_file(in_file.read)
          rescue ArgumentError, TypeError => e
            @scores[file_title] = {:elapsed_time => 0}
          end
        end
      end
      @scores
    end

    def to_h
      {:perf => @scores}
    end

    def process_wall_time_file(csv_content)
      parse_array_into_score_item(CSV.parse(csv_content).last)
    end

    def parse_array_into_score_item(row)
      elapsed_time = Float(row[0])
      {:elapsed_time => elapsed_time}
    end

  end
end