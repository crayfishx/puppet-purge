require 'spec_helper'

purge = Puppet::Type.type(:purge)


describe purge do

  before :each do
    
    @system_resources = [
      Puppet::Type.type(:user).new(:name => 'kermit_123',  :uid => '501'),
      Puppet::Type.type(:user).new(:name => 'deadman_123', :uid => '600'),
      Puppet::Type.type(:user).new(:name => 'deadman_456', :uid => '601'),
      Puppet::Type.type(:user).new(:name => 'deadman_789', :uid => '602'),
    ]


    @resources = [
      Puppet::Type.type(:user).new(:name => 'kermit_123', :uid => '501'),
      Puppet::Type.type(:user).new(:name => 'gonzo_123', :uid => '501')
    ]
    @catalog = Puppet::Resource::Catalog.new
    @resources.each { |r| @catalog.add_resource r }

    Puppet::Type.type(:user).stubs(:instances).returns(@system_resources)
    
  end


  context "when initialized" do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user')
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should do return an array" do
      expect(@output).to be_a(Array)
    end

    it "should only contain user resources" do
      expect do
        @output.map { |r| r.class}.uniq.to eq( [ Puppet::Type::User ] )
      end
    end


    it "should purge the deadman user" do
      deadman = @output.select { |r| r.name == 'deadman_123' }[0]
      expect(deadman[:ensure]).to eq(:absent)
    end

    it "should not try and manage the user in the catalog" do
      users = @output.map { |r| r.name }
      expect(users).not_to include('kermit_123')
      expect(users).not_to include('gonzo_123')
    end
  end

  context "When running with if filter == " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :if =>  [ "uid", "==", "600" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should contain only the deadman_123 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_123'] )
    end

    it "should set ensure to absent for the deadman_123 user" do
      expect(@output[0][:ensure]).to eq(:absent)
    end
  end


  context "When running with if filter =~ " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :if =>  [ "name", "=~", "dead.*_123" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should contain only the deadman_123 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_123'] )
    end

    it "should set ensure to absent for the deadman_123 user" do
      expect(@output[0][:ensure]).to eq(:absent)
    end
  end


  context "When running with if filter >= " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :if =>  [ "uid", ">=", "602" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should contain only the deadman_789 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_789'] )
    end

    it "should set ensure to absent for the deadman_789 user" do
      expect(@output[0][:ensure]).to eq(:absent)
    end
  end


  context "When running with if filter <= " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :if =>  [ "uid", "<=", "600" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should contain only the deadman_123 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_123'] )
    end

    it "should set ensure to absent for the deadman_123 user" do
      expect(@output[0][:ensure]).to eq(:absent)
    end
  end


  context "When running with if filter > " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :if =>  [ "uid", ">", "601" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should contain only the deadman_789 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_789'] )
    end

    it "should set ensure to absent for the deadman_789 user" do
      expect(@output[0][:ensure]).to eq(:absent)
    end
  end


  context "When running with if filter < " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :if =>  [ "uid", "<", "601" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should contain only the deadman_123 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_123'] )
    end

    it "should set ensure to absent for the deadman_123 user" do
      expect(@output[0][:ensure]).to eq(:absent)
    end
  end


  context "When running with unless filter == " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :unless =>  [ "uid", "==", "600" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should not contain the deadman_123 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_456', 'deadman_789'] )
    end

  end


  context "When running with unless filter =~ " do
    before do
      @purge = Puppet::Type.type(:purge).new(:name => 'user', :unless =>  [ "name", "=~", "dead.*_123" ] )
      @catalog.add_resource(@purge)
      @output = @purge.generate
    end

    it "should not contain the deadman_123 user" do
      users = @output.map { |r| r.name }
      expect(users).to eq( ['deadman_456', 'deadman_789'] )
    end
  end


end

