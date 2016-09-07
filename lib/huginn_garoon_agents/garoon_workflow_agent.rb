require 'ragoon'

module Agents
  class GaroonWorkflowAgent < Agent

    FOLDER_TYPE = %w{unprocessed received sent}

    can_dry_run!
    can_order_created_events!
    no_bulk_receive!
    cannot_receive_events!

    description <<-MD
      Garoon Workflow API
    MD

    event_description  <<-MD
      Garoon Workflow API event
    MD

    default_schedule "every_10m"

    def default_options
      {
        endpoint: "Endpoint URL (https://example.com/grn.exe)",
        username: "Username",
        password: "Password",
        folder_type: "sent",
        within_minutes: 60,
      }
    end

    def validate_options
      errors.add(:base, 'endpoint is required') unless options['endpoint'].present?
      errors.add(:base, 'username is required') unless options['username'].present?
      errors.add(:base, 'password is required') unless options['password'].present?
      errors.add(:base, 'folder_type is required') unless options['folder_type'].present?
      errors.add(:base, 'folder_type is invalid') unless FOLDER_TYPE.include?(options['folder_type'])
      errors.add(:base, 'within_minutes must be a number') unless options['within_minutes'].to_i > 0
    end

    def working?
      !recent_error_logs?
    end

    def check
      prev = memory['items'] || []
      items = get_application_versions(prev)

      log(items)

      id_list = []
      new_items = []
      items.each do |item|
        id_list << item[:id]
        new_items << item unless item[:operation] == 'remove'
      end

      details = get_applications_by_id(new_items.map {|i| i[:id]})
      details = Hash[details.map{|i| [ i[:id], i] }]

      items.each do |item|
        create_event :payload => item.merge(detail: details[item[:id]])
      end

      memory['items'] = new_items + prev.reject {|i| id_list.include?(i[:id]) }
    end

    private

    def workflow
      Ragoon::Services::Workflow.new(
        endpoint: interpolated['endpoint'],
        username: interpolated['username'],
        password: interpolated['password'],
      )
    end

    def get_application_versions(items)
      type = interpolated["folder_type"]

      args = [items]
      if type != "unprocessed"
        args << { start_date: Time.now - (60 * interpolated["within_minutes"].to_i) }
      end

      methods_table = Hash[FOLDER_TYPE.map{|t| [t, "workflow_get_#{t}_application_versions"]}]
      workflow.send(methods_table[type], *args)
    end

    def get_applications_by_id(id_list)
      type = interpolated["folder_type"]
      methods_table = Hash[FOLDER_TYPE.map{|t| [t, "workflow_get_#{t}_applications_by_id"]}]
      workflow.send(methods_table[type], id_list)
    end

  end
end
