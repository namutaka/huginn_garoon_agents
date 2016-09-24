ENV['RESTCLIENT_LOG'] ='stdout'
base_path = File.expand_path('../', __FILE__)
require 'rails_helper'
require 'huginn_agent/spec_helper'
require "#{base_path}/spec_helper"
require 'pp'


describe Agents::GaroonWorkflowAgent do
  let(:default) { Agents::GaroonWorkflowAgent.new.default_options }
  let(:agent) {
    _agent = Agents::GaroonWorkflowAgent.new(
      name: 'GaroonWorkflowAgent', options: options)
    _agent.user = users(:bob)
    _agent.save!
    _agent
  }

  describe "#check" do
    let(:options) {
      default.merge(
        endpoint: "http://onlinedemo2.cybozu.info/scripts/garoon/grn.exe",
        username: "sato",
        password: "sato",
        folder_type: "sent",
        within_minutes: (( Time.now - Time.new(2011, 5, 25, 10, 00) ) / 60).to_i,
      )
    }

    it "should get events" do
      agent.memory["items"] = [
        {"id": "33", "version": "1500000000", "operation": "modify"},
        {"id": "32", "version": "1416375465", "operation": "add"},
        {"id": "31", "version": "1415179601", "operation": "add"},
        {"id": "21", "version": "1415185970", "operation": "add"},
      ]

      VCR.use_cassette 'garoon_workflow_agent' do
        expect {
          agent.check
        }.to change { Event.count }.by(4)
      end

      expect(agent.memory["items"]).to contain_exactly(
        {"id": "32", "version": "1416375465", "operation": "add"},
        {"id": "31", "version": "1415179601", "operation": "add"},
        {"id": "22", "version": "1306486534", "operation": "add"},
        {"id": "21", "version": "1415185979", "operation": "modify"},
        {"id": "20", "version": "1306486544", "operation": "add"}
      )

      events = Event.last(4)
      expect(events.map(&:payload)).to contain_exactly(
        include("id": "33", "version": "0",          "operation": "remove",
               "detail": nil),
        include("id": "22", "version": "1306486534", "operation": "add",
               "detail": include("id": "22")),
        include("id": "21", "version": "1415185979", "operation": "modify",
               "detail": include("id": "21")),
        include("id": "20", "version": "1306486544", "operation": "add",
               "detail": include("id": "20")),
      )
    end
  end

end

