require "spec_helper"

describe Affiliate, :type => :model do

  it "#current should return nil by default" do
    Affiliate.current.should == nil
  end

  context "when params are invalid" do
    let(:honyb_id) {'invalid'}
    
    it "#init should throw an exception" do
      begin
        Affiliate.init({:honyb_id => honyb_id}, {})
        raise StandardError, "should not get here"
      rescue ActiveRecord::RecordNotFound => e
        puts e.message
        e.message.should == %Q{Couldn't find Affiliate with honyb_id = #{honyb_id}}
      end
    end
  end

end