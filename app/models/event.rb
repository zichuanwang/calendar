class Event < ActiveRecord::Base
    belongs_to :cal
    belongs_to :user

    def self.parse_time(obj, key)
        result = nil
        return if not obj[key]
        value = obj[key]['dateTime']
        value = obj[key]['date'] if not value
        begin
            result = DateTime.parse(value)
        rescue => err
            Rails.logger.error "error: #{err}, #{obj['key']}, #{obj}"
        end
        result
    end

    def self.create_or_update_with_gmail_event(obj, user_id, calendar_id)
        event_id = obj['id']
        event = Event.where(:event_id => event_id).where(:user_id => user_id).first_or_create
        event.title = obj['summary']
        event.cal_id = Cal.where(:calendar_id => calendar_id).first.id
        event.description = obj['description']
        event.start_time = parse_time(obj, 'start')
        event.end_time = parse_time(obj, 'end')
        event.save
    end

    def json_presentation
        json = {}
        json[:id] = self.id
        json[:title] = self.title
        json[:start] = self.start_time.strftime("%Y-%m-%d %H:%M:%S")
        json[:end] = self.end_time.strftime("%Y-%m-%d %H:%M:%S")
        json[:description] = self.description
        json
    end
end
