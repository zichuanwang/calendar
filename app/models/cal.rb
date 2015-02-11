class Cal < ActiveRecord::Base
    has_many :events
    belongs_to :user

    def self.create_or_update_with_google_calendar(cal_obj, user_id)
        calendar_id = cal_obj['id']
        cal = Cal.where(:calendar_id => calendar_id).where(:user_id => user_id).first_or_create
        cal.calendar_id = calendar_id
        cal.background_color = cal_obj['backgroundColor']
        cal.foreground_color = cal_obj['foregroundColor']
        cal.user_id = user_id
        cal.name = cal_obj['summary']
        cal.save
    end
end
