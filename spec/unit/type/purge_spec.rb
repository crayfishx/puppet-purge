require 'spec_helper'

purge = Puppet::Type.type(:purge)


describe purge do

  before :each do
    
    @system_resources = [
      Puppet::Type.type(:user).new(:name => 'kermit_123',  :uid => '501'),
      Puppet::Type.type(:user).new(:name => 'deadman_123', :uid => '600'),
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

    it "should do something" do
      expect(@output).to be_a(Array)
    end

    it "should only contain user resources" do
      expect do
        @output.map { |r| r.class}.uniq.to eq( [ Puppet::Type::User ] )
      end
    end


    it "should purge the deadman user" do
      expect do
        @output.select { |r| r.name == 'deadman_123' }[0][:ensure].to eq('absent')
      end
    end

    it "should not try and manage the user in the catalog" do
      expect do
        @output.map { |r| r.name }.not_to include('kermit_123')
      end
      expect do
        @output.map { |r| r.name }.not_to include('gonzo_123')
      end
    end



  end
end

