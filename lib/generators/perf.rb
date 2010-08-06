require 'enumerator'

module MetricFu
  class Perf < Generator
    NEW_FILE_MARKER =  ("=" * 80) + "\n"
    def emit
      clean_scratch_directory
      run_performance_tests
    end

    def analyze

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