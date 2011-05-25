require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper

describe ApplicationHelper do
  describe "#cleanse" do
    it "should preserve plain text" do
      helper.cleanse("Allison to Lillia").should == "Allison to Lillia"
    end
    
    it "should remove unsafe tags" do
      helper.cleanse("<script>Fiona</script>").should == "Fiona"
    end

    it "should encode HTML entities" do
      helper.cleanse("Allison & Lillia").should == "Allison &amp; Lillia"
    end

    it "should preserve HTML entities" do
      helper.cleanse("Allison &amp; Lillia").should == "Allison &amp; Lillia"
    end

    it "should close tags" do
      helper.cleanse("<b>Fiona").should == "<b>Fiona</b>"
    end
  end
end
