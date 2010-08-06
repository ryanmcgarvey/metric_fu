require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::Perf do
  
  before :each do
    MetricFu::Configuration.run {}
    @perf = MetricFu::Perf.new('base_dir')
  end

  describe "emit method" do

    before :each do
      #@perf.stub!(:puts)
    end

    it "should clear out previous output and create new output folder" do
      @perf.stub!(:`)
      FileUtils.should_receive(:rm_rf).with(MetricFu::Perf.metric_directory, :verbose => false)
      Dir.should_receive(:mkdir).with(MetricFu::Perf.metric_directory)
      @perf.emit
    end

    it "should set the RAILS_ENV" do
      FileUtils.stub!(:rm_rf)
      Dir.stub!(:mkdir)
      MetricFu.perf[:environment] = "metrics"
      @perf.should_receive(:`).with(/RAILS_ENV=metrics/)
      @perf.emit
    end

    it "should write results to output file" do
      FileUtils.stub!(:rm_rf)
      Dir.stub!(:mkdir)
      MetricFu.perf[:environment] = "metrics"
      @perf.should_receive(:`).with(/>> .*perf\.txt/)
      @perf.emit
    end
  end

    it "should run the performance tests" do
      #@perf.stub!(:`)
      @perf.should_receive(:run_performance_tests)
      @perf.emit
    end
  

  PERF_OUTPUT = <<-HERE
(in /home/e3/dev/webTAC)
Loaded suite /home/e3/.rvm/gems/ree-1.8.7-2010.02/gems/rake-0.8.7/lib/rake/rake_test_loader
Started
FrontPageTest#test_portal (10 ms warmup)
           wall_time: 13 ms
              memory: 979.51 KB
             objects: 8859
             gc_runs: 0
             gc_time: 0 ms
.PortalTest#test_portal (3 ms warmup)
           wall_time: 9 ms
              memory: 979.51 KB
             objects: 8859
             gc_runs: 0
             gc_time: 0 ms
.
Finished in 1.05824 seconds.

10 tests, 0 assertions, 0 failures, 0 errors

TEST BENCHMARK TIMES: OVERALL
0.590 test_portal(FrontPageTest)
0.467 test_portal(PortalTest)

Test Benchmark Times: Suite Totals:
0.590 FrontPageTest
0.467 PortalTest

HERE


end