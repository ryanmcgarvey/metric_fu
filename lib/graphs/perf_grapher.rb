module MetricFu
  class PerfGrapher < Grapher
    attr_accessor :test_runs_list, :labels
    def initialize
      self.labels = {}
      self.test_runs_list = {}
    end

    def push_score_to_test(test_run_name, score)
      self.test_runs_list[test_run_name] ||= []
      self.test_runs_list[test_run_name].push(score)
    end

    def get_metrics(metrics, date)
      if metrics && metrics[:perf]
        metrics[:perf].each_pair do |test_run_name, score|
          push_score_to_test(test_run_name, score[:elapsed_time])
        end
        self.labels.update( { self.labels.size => date })
      end
    end
  end
end