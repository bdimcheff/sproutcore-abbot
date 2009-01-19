require File.join(File.dirname(__FILE__), %w(.. spec_helper))

# Creates combined entries for javascript & css
describe "manifest:prepare_build_tasks:combine" do
  
  include SC::SpecHelpers
  include SC::ManifestSpecHelpers
  
  before do
    std_before
  end
  
  def run_task
    @manifest.prepare!
    super('manifest:prepare_build_tasks:combine')
  end

  it "should run setup, javascript, css, & sass as prereq" do
    %w(setup javascript css sass).each do |task_name|
      should_run("manifest:prepare_build_tasks:#{task_name}") { run_task }
    end
  end

  #######################################
  # stylesheet.css support
  #
  describe "whem CONFIG.combine_stylesheet = true" do
    
    before do
      @config.combine_stylesheet = true
      run_task
    end
    
    it "creates a combined stylesheet entry for each resource named in files" do
      # spot check...
      entry = entry_for 'stylesheet.css'
      expected = entry_for('has_require.css', :entry_type => :css)
      entry.source_entries.should include(expected)

      expected = entry_for('no_require.css', :entry_type => :css)
      entry.source_entries.should include(expected)

      # Test that sass file is included...
      expected = entry_for('demo2.css', :entry_type => :css)
      entry.source_entries.should include(expected)

      entry = entry_for 'bar.css'
      expected = entry_for('sc_resource.css', :entry_type => :css)
      entry.source_entries.should include(expected)
    end
    
    it "entries have a build_task = build:combine:css" do
      entry_for('stylesheet.css').build_task.should == 'build:combine:css'
      entry_for('bar.css').build_task.should == 'build:combine:css'
    end
    
    it "hides source entries" do
      %w(stylesheet.css bar.css).each do |filename|
        entry_for(filename).source_entries.each do |entry|
          entry.should be_hidden
        end
      end
    end
    
    
    describe "adds ENTRY.ordered_entries propery with entries following load order" do
      
      before do
        @project = fixture_project :ordered_entries
      end
      
      it "orders entries as lproj/strings -> core -> utils -> others alphabetically without requires" do
        
        @target = @project.target_for :no_requires
        @buildfile = @target.buildfile
        @config = @target.config
        @manifest = @target.manifest_for(:language => :en)
        @target.prepare! # make sure its ready for the manifest...
        
        run_task
        entry = @manifest.entry_for('stylesheet.css')

        # get the expected set of ordered entries...based on contents of 
        # project...
        expected = %w(a.css a/a.css a/b.css B.css b/a.css c.css)

        entry.ordered_entries.should_not be_nil
        filenames = entry.ordered_entries.map { |e| e.filename }
        filenames.should eql(expected)
      end

      it "will override default order respecting ENTRY.required" do
        
        @target = @project.target_for :with_requires
        @buildfile = @target.buildfile
        @config = @target.config
        @manifest = @target.manifest_for(:language => :en)
        @target.prepare! # make sure its ready for the manifest...
        
        run_task
        entry = @manifest.entry_for('stylesheet.css')

        # get the expected set of ordered entries...based on contents of 
        # project...
        expected = %w(c.css a.css b.css)

        entry.ordered_entries.should_not be_nil
        filenames = entry.ordered_entries.map { |e| e.filename }
        filenames.should eql(expected)
      end
      
    end
    
  end

  describe "when CONFIG.combine_stylesheet = false" do
    
    before do
      @config.combine_stylesheet = false
      run_task
    end
    
    it "still creates combined CSS entry" do
      entry = entry_for('stylesheet.css')
      entry.should_not be_nil
    end
    
    it "does not hide source CSS entries" do
      entry = entry_for('stylesheet.css')
      entry.should_not be_nil
      entry.source_entries.each { |entry| entry.should_not be_hidden }
    end
  end
  
  #######################################
  # javascript.js support
  #

  describe "whem CONFIG.combine_javascript = true" do
    
    before do
      @config.combine_javascript = true
      run_task
    end
    
    it "creates a combined JS entry for each resource named in files" do
      # spot check...
      entry = entry_for 'javascript.js'
      expected = entry_for('has_require.js', :entry_type => :javascript)
      entry.source_entries.should include(expected)

      expected = entry_for('no_require.js', :entry_type => :javascript)
      entry.source_entries.should include(expected)

      entry = entry_for 'bar.js'
      expected = entry_for('sc_resource.js', :entry_type => :javascript)
      entry.source_entries.should include(expected)
    end
    
    it "entries have a build_task = build:combine:javascript" do
      %w(javascript.js bar.js).each do |filename|
        entry_for(filename).build_task.should == 'build:combine:javascript'
      end
    end
    
    it "hides source entries" do
      %w(javascript.js bar.js).each do |filename|
        entry_for(filename).source_entries.each do |entry|
          entry.should be_hidden
        end
      end
    end
    
    describe "adds ENTRY.ordered_entries propery with entries following load order" do
      
      before do
        @project = fixture_project :ordered_entries
      end
      
      it "orders entries as lproj/strings -> core -> utils -> others alphabetically without requires" do
        
        @target = @project.target_for :no_requires
        @buildfile = @target.buildfile
        @config = @target.config
        @manifest = @target.manifest_for(:language => :en)
        @target.prepare! # make sure its ready for the manifest...
        
        run_task
        entry = @manifest.entry_for('javascript.js')

        # get the expected set of ordered entries...based on contents of 
        # project...
        expected = %w(lproj/strings.js core.js utils.js 1.js a.js a/a.js a/b.js B.js b/a.js c.js)

        entry.ordered_entries.should_not be_nil
        filenames = entry.ordered_entries.map { |e| e.filename }
        filenames.should eql(expected)
      end

      it "will override default order respecting ENTRY.required" do
        
        @target = @project.target_for :with_requires
        @buildfile = @target.buildfile
        @config = @target.config
        @manifest = @target.manifest_for(:language => :en)
        @target.prepare! # make sure its ready for the manifest...
        
        run_task
        entry = @manifest.entry_for('javascript.js')

        # get the expected set of ordered entries...based on contents of 
        # project...
        expected = %w(c.js a.js lproj/d.js b.js)

        entry.ordered_entries.should_not be_nil
        filenames = entry.ordered_entries.map { |e| e.filename }
        filenames.should eql(expected)
      end
      
    end
    
  end

  describe "when CONFIG.combine_javascript = false" do
    
    before do
      @config.combine_javascript = false
      run_task
    end
    
    it "still creates combined JS entry" do
      entry = entry_for('javascript.js')
      entry.should_not be_nil
    end
    
    it "does not hide source JS entries" do
      entry = entry_for('javascript.js')
      entry.should_not be_nil
      entry.source_entries.each { |entry| entry.should_not be_hidden }
    end
  end

end