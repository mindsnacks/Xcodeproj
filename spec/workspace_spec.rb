require File.expand_path('../spec_helper', __FILE__)

describe "Xcodeproj::Workspace::WorkspaceItem" do
	describe "from empty" do

    before do
      @item = Xcodeproj::Workspace::WorkspaceItem.new
    end

		it "does not raise on valid location type" do
			Xcodeproj::Workspace::WorkspaceItem::LOCATION_TYPES.each do |type| 
				@item.location_type = type
				@item.location_type.should == type
			end
		end

		it "raises on invalid location type" do
			lambda { @item.location_type = "banana" }.should.raise
		end

	end
end

describe "Xcodeproj::Workspace::Group" do

	describe "from empty" do
    before do
      @group = Xcodeproj::Workspace::Group.new('Test')
    end

		it "does not contain any children" do
			@group.contents.should.be.empty
		end

		it "accepts new children" do
			@group.contents << Xcodeproj::Workspace::Group.new('Child')
			@group.contents.first.isa.should == 'Group'
			@group.contents.first.name.should == 'Child'
		end

	end
end

describe "Xcodeproj::Workspace" do

	describe "from empty" do
    before do
      @workspace = Xcodeproj::Workspace.new
    end

    it "does not contain any projects" do
			@workspace.projpaths.should.be.empty
			@workspace.include?('Framework.xcodeproj').should == false
		end

		it "accepts new groups" do
			@workspace << Xcodeproj::Workspace::Group.new('Child')
			@workspace.contents.first.isa.should == 'Group'
			@workspace.contents.first.name.should == 'Child'
		end

		it "finds project within a group" do
			group = Xcodeproj::Workspace::Group.new('Projects')
			@workspace.contents << group
			group << Xcodeproj::Workspace::FileRef.new('Framework.xcodeproj')
			@workspace.include?('Framework.xcodeproj').should == true
		end

	end

  describe "from new with contents" do
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
