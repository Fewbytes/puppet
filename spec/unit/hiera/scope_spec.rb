require 'spec_helper'
require 'hiera/scope'

describe Hiera::Scope do
  describe "#initialize" do
    it "should store the supplied puppet scope" do
      real = {}
      scope = Hiera::Scope.new(real)
      scope.real.should == real
    end
  end

  describe "#[]" do
    it "should return nil when no value is found" do
      real = mock
      real.expects(:lookupvar).with("foo").returns(nil)

      scope = Hiera::Scope.new(real)
      scope["foo"].should == nil
    end

    it "should treat '' as nil" do
      real = mock
      real.expects(:lookupvar).with("foo").returns("")

      scope = Hiera::Scope.new(real)
      scope["foo"].should == nil
    end

    it "sould return found data" do
      real = mock
      real.expects(:lookupvar).with("foo").returns("bar")

      scope = Hiera::Scope.new(real)
      scope["foo"].should == "bar"
    end

    it "should get calling_class and calling_module from puppet scope" do
      real = Puppet::Parser::Scope.new_for_test_harness("test_node")
      source = mock
      source.expects(:type).returns(:hostclass).once
      source.expects(:name).returns("Foo::Bar").once
      source.expects(:module_name).returns("foo").once
      real.expects(:source).returns(source).at_least_once

      scope = Hiera::Scope.new(real)
      scope["calling_class"].should == "foo::bar"
      scope["calling_module"].should == "foo"
    end
  end

  describe "#include?" do
    it "should correctly report missing data" do
      real = mock
      real.expects(:lookupvar).with("foo").returns("")

      scope = Hiera::Scope.new(real)
      scope.include?("foo").should == false
    end

    it "should always return true for calling_class and calling_module" do
      real = mock
      real.expects(:lookupvar).with("calling_class").never
      real.expects(:lookupvar).with("calling_module").never

      scope = Hiera::Scope.new(real)
      scope.include?("calling_class").should == true
      scope.include?("calling_module").should == true
    end
  end
end
