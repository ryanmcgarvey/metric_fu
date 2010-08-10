require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::Perf do

  before :each do
    MetricFu::Configuration.run {}
    @perf = MetricFu::Perf.new('base_dir')
  end

  describe "emit method" do

    it "should set the RAILS_ENV" do
      MetricFu.perf[:environment] = "metrics"
      @perf.should_receive(:`).with(/RAILS_ENV=metrics/)
      @perf.emit
    end
  end

  describe "analyze method" do

    it "should open each wall time csv file and process each line" do
      #files = PERF_WALL_TIME_FILES.keys.inject(""){}
      prepended_list = []
      PERF_WALL_TIME_FILES.keys.each do |key|
        prepended_list << MetricFu.perf[:output_directory] + "/" + key
      end
      Dir.should_receive(:[]).
              with(/.*wall_time.csv/).
              and_return(prepended_list)
      PERF_WALL_TIME_FILES.keys.each do |test_file_name|
        mock_file = mock("io", :read => "some stuff")
        File.should_receive(:open).
                with(MetricFu.perf[:output_directory] + "/" + test_file_name).
                and_yield(mock_file)
        @perf.should_receive(:process_wall_time_file).with("some stuff")
      end
      @perf.analyze
    end

    it "should create a hash with the value as an array of scores" do
      file_name = 'file_name'
      score_values = [1,2,3,4,5,6,8,9]

      Dir.stub!(:[]).
              with(/.*wall_time.csv/).
              and_return(file_name)
      File.stub!(:open).and_yield(StringIO.new('a value'))
      @perf.stub!(:process_wall_time_file).and_return(score_values)
      scores = @perf.analyze
      
      scores[file_name].should == score_values
    end

    it "should create a hash with a key for each file" do
      Dir.should_receive(:[]).
              with(/.*wall_time.csv/).
              and_return(PERF_WALL_TIME_FILES.keys)

      File.stub!(:open).and_yield(StringIO.new(''))
      scores = @perf.analyze
      scores.each_pair do |file_name, scores|
        PERF_WALL_TIME_FILES.should have_key file_name
      end

    end

  end


  describe "to_h method" do
    it "should put things into a hash" do
      score_content = "something"
      @perf.instance_variable_set(:@scores, score_content)
      @perf.to_h[:perf].should == score_content
    end
  end

  describe "process_wall_time_file method" do
    it "should parse csv into array of scores" do
      wall_time_content = PERF_WALL_TIME_FILES["FrontPageTest#test_portal_wall_time.csv"]
      scores = @perf.process_wall_time_file(wall_time_content)
      scores.size.should == 17
      scores.first[:score].should ==0.0126267671585083
      scores.first[:time].should ==DateTime.parse("2010-08-04T19:46:16Z")
      scores.last[:score].should == 0.0131937265396118
      scores.last[:time].should == DateTime.parse("2010-08-06T20:39:03Z")
    end
  end

  describe "parse_line_into_score_item" do
    it "should return the correct score item to a correct line" do
      row = ["0.0131937265396118", "2010-08-06T20:39:03Z", nil, "2.3.4", "ruby-1.8.7.253", "x86_64-linux"]
      score_item = @perf.parse_array_into_score_item(row)
      score_item[:score].should == 0.0131937265396118
      score_item[:time].should == DateTime.parse("2010-08-06T20:39:03Z")
    end

    it "should raise if the first item is not a float" do
      row = ["measurement", "2010-08-06T20:39:03Z", "app", "rails", "ruby", "platform"]
      lambda {@perf.parse_array_into_score_item(row)}.should raise_error(ArgumentError)
    end

    it "should raise if the second item is not a date" do
      row = ["0.1", "created_at", "app", "rails", "ruby", "platform"]
      lambda {@perf.parse_array_into_score_item(row)}.should raise_error(ArgumentError)
    end

    it "should raise if the array is empty or nil" do
      row = [nil, nil]
      lambda {@perf.parse_array_into_score_item(row)}.should raise_error
    end 
  end

  PERF_WALL_TIME_FILES = {}
  PERF_WALL_TIME_FILES["FrontPageTest#test_portal_wall_time.csv"] = <<-HERE
measurement,created_at,app,rails,ruby,platform
0.0126267671585083,2010-08-04T19:46:16Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0125694274902344,2010-08-04T20:07:17Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0126004815101624,2010-08-04T20:09:01Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0128989815711975,2010-08-04T20:09:16Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0129777193069458,2010-08-04T20:11:01Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0,2010-08-05T15:35:05Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0,2010-08-05T20:41:33Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0,2010-08-05T20:46:14Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0146334767341614,2010-08-05T20:49:00Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.013060986995697,2010-08-05T20:56:38Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0128282904624939,2010-08-05T21:03:02Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0129525065422058,2010-08-05T21:59:35Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0125052332878113,2010-08-05T22:00:02Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0131164789199829,2010-08-06T14:45:57Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0130281448364258,2010-08-06T19:17:25Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.012207567691803,2010-08-06T20:28:19Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0131937265396118,2010-08-06T20:39:03Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
  HERE

  PERF_WALL_TIME_FILES["PortalTest#test_portal_wall_time.csv"] = <<-HERE
measurement,created_at,app,rails,ruby,platform
0.0162451863288879,2010-08-04T19:28:56Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0126134753227234,2010-08-04T19:29:55Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0137957334518433,2010-08-04T19:30:32Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00890654325485229,2010-08-04T19:46:17Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00900155305862427,2010-08-04T20:07:17Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00916147232055664,2010-08-04T20:09:01Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00844573974609375,2010-08-04T20:09:16Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00883245468139648,2010-08-04T20:11:02Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0,2010-08-05T15:35:56Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0,2010-08-05T20:42:27Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0,2010-08-05T20:47:04Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00931674242019653,2010-08-05T20:49:01Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00974112749099731,2010-08-05T20:56:39Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00940698385238647,2010-08-05T21:03:03Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00932127237319946,2010-08-05T21:59:35Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00893598794937134,2010-08-05T22:00:02Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0094340443611145,2010-08-06T14:45:57Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00948184728622437,2010-08-06T19:17:25Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00946003198623657,2010-08-06T20:28:19Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.0095818042755127,2010-08-06T20:39:03Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
  HERE
  PERF_WALL_TIME_FILES["PortalTest#test_portal_again_wall_time.csv"] = <<-HERE
measurement,created_at,app,rails,ruby,platform
0.00963455438613892,2010-08-06T20:28:20Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
0.00959175825119019,2010-08-06T20:39:04Z,,2.3.4,ruby-1.8.7.253,x86_64-linux
  HERE



end