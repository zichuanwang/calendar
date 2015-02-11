class Event < ActiveRecord::Base
    belongs_to :cal

    def configure_time(obj, key)
        return if not obj[key]
        value = obj[key]['dateTime']
        value = obj[key]['date'] if not value
        begin
            self.start_time = DateTime.parse(value)
        rescue => err
            Rails.logger.error "error: #{err}, #{obj['key']}, #{obj}"
        end
    end

    def self.create_or_update_with_gmail_event(obj, user_id)
        event_id = obj['id']
        event = Event.where(:event_id => event_id).where(:user_id => user_id).first_or_create
        event.title = obj['summary']
        event.description = obj['description']
        event.configure_time(obj, 'start')
        event.configure_time(obj, 'end')
        event.save
    end 
end
