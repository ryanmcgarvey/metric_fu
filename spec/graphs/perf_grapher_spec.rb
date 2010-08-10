require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")


describe PerfGrapher do
  before :each do
    @perf_grapher= MetricFu::PerfGrapher.new
    MetricFu.configuration
  end

  it "should respond to test_runs_list" do
    @perf_grapher.should respond_to(:test_runs_list)
  end

  describe "responding to #get_metrics" do
    context "when metrics were not generated" do
      before(:each) do
        @metrics = YAML::load(File.open(File.join(File.dirname(__FILE__), "..", "resources", "yml", "metric_missing.yml")))
        @date = "01022003"
      end

      it "should not update test_runs_list" do
        @perf_grapher.test_runs_list.should_not_receive(:update)
        @perf_grapher.get_metrics(@metrics, @date)
      end

      it "should not update labels with the date" do
        @perf_grapher.labels.should_not_receive(:update)
        @perf_grapher.get_metrics(@metrics, @date)
      end
    end
    context "when metrics were generated" do
      before(:each) do
        @metrics = YAML::load(File.open(File.join(File.dirname(__FILE__), "..", "resources", "yml", "20090630.yml")))
        @date = "20090630"
      end
      it "should contain test_run_list corresponding to yaml file" do
        @perf_grapher.get_metrics(@metrics, @date)
        @perf_grapher.test_runs_list.size.should == 3
      end

      it "should push to test_runs_list[PortalTest]" do

        @perf_grapher.should_receive(:push_score_to_test).with("tmp/performance/FrontPageTest#test_portal_wall_time.csv", 0.0142309665679932)
        @perf_grapher.should_receive(:push_score_to_test).with("tmp/performance/PortalTest#test_portal_wall_time.csv", 0.00888323783874512)
        @perf_grapher.should_receive(:push_score_to_test).with("tmp/performance/PortalTest#test_portal_again_wall_time.csv", 0.00926393270492554)
        @perf_grapher.get_metrics(@metrics, @date)
      end
    end
  end





end