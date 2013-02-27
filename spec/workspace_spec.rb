require File.expand_path('../spec_helper', __FILE__)

describe "Xcodeproj::Workspace" do

	describe "from empty" do
    before do
      @workspace = Xcodeproj::Workspace.new
    end

    it "it does not contain any projects" do
			@workspace.projpaths.should.be.empty
			@workspace.include?('Framework.xcodeproj').should == false
		end

		it "accepts new groups" do
			@workspace << Xcodeproj::Workspace::Group.new('whee')
			@workspace.contents.first.isa.should == 'Group'
			@workspace.contents.first.name.should == 'whee'
		end

	end

  describe "from new" do
    before do
      @workspace = Xcodeproj::Workspace.new('Pods/Pods.xcodeproj', 'App.xcodeproj')
    end

    it "accepts new projects" do
      @workspace << 'Framework.xcodeproj'
      @workspace.projpaths.should.include 'Framework.xcodeproj'
			@workspace.include?('Framework.xcodeproj').should == true
    end

  end

  describe "converted to XML" do
    before do
      @workspace = Xcodeproj::Workspace.new('Pods/Pods.xcodeproj', 'App.xcodeproj')
      @doc = REXML::Document.new(@workspace.to_s)
    end

    it "is the right xml workspace version" do
      @doc.root.attributes['version'].to_s.should == "1.0"
    end

    it "refers to the projects in xml" do
      @doc.root.get_elements("/Workspace/FileRef").map do |node|
        node.attributes["location"]
      end.sort.should == ['group:App.xcodeproj', 'group:Pods/Pods.xcodeproj']
    end
  end

  describe "built from a workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("libPusher.xcworkspace"))
    end

    it "contains all of the projects in the workspace" do
      @workspace.projpaths.should.include "libPusher.xcodeproj"
      @workspace.projpaths.should.include "libPusher-OSX/libPusher-OSX.xcodeproj"
      @workspace.projpaths.should.include "Pods/Pods.xcodeproj"
    end
  end

  describe "built from an empty/invalid workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace("doesn't exist")
    end

    it "contains no projects" do
      @workspace.projpaths.should.be.empty
    end
  end
end
