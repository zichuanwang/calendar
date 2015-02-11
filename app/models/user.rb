class User < ActiveRecord::Base
    has_many :events
    has_many :cals

    def ready?
        not self.calendar_list_sync_token.nil?
    end

    def json_presentation
        json = { :user_id => self.id }
        if self.ready?
            cals = []
            self.cals.each { |cal| cals << cal.json_presentation }
            json[:calendars] = cals
        end
        json
    end
end
