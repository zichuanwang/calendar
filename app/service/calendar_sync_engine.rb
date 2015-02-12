require 'thread/pool'

class InvalidCredentialsException < Exception
end

class CalendarSyncEngine
    def initialize 
        @sync_pool = Thread.pool(20)
    end

    def start
        # if Rails.env.daemon?
        Rails.logger.info 'start calendar sync engine'
        sync_calendar_for_all_users
        # end
    end

    private

    def sync_calendar_for_all_users
        Thread.new do
            loop do
                start_time = Time.new
                all_user_ids.each do |user_id|
                    sync_calendar_for_user(user_id)
                end
                elapse = Time.new - start_time
                sleep(1 - elapse) if elapse < 1
            end
        end
    end

    def sync_calendar_for_user(user_id)
        # check if we are already syncing for this user
        already_syncing = start_sync_calendar_for_user(user_id)
        return false if already_syncing

        sync_in_background do
            start_time = Time.new
            begin
                fetched_new = sync_calendar_for_user_helper(user_id)
                Rails.logger.info "fetched new for user #{user_id}" if fetched_new

                push_notification(user_id, :fetched_new, 'fetched new calendar') if fetched_new
                        
            rescue => err
                trace = err.backtrace.join("\n")
                Rails.logger.error "error happens when syncing calendar for user #{user_id}, message: #{err.message}\ntrace: #{trace}"
            ensure
                finish_sync_calendar_for_user(user_id)
                Rails.logger.info "it took #{Time.new - start_time} seconds to finish syncing calendar for user #{user_id}"
            end
        end
        return true
    end

    # list

    def list_calendars_list_for_user(user_id, page_token, sync_token)
        access_token = access_token_for_user(user_id)

        url = "https://www.googleapis.com/calendar/v3/users/me/calendarList?&access_token=#{access_token}"
        url = url + "&pageToken=#{page_token}" if not page_token.nil?
        url = url + "&syncToken=#{sync_token}" if not sync_token.nil?

        response = HTTParty.get(url)
        json = nil
        if response.code == 200
            json = JSON.parse(response.body)
        else
            Rails.logger.error "unable to list calendars for #{user_id}"
            Rails.logger.error "list calendars response body: #{response.body}"
        end
        json
    end

    def list_events_for_user(user_id, calendar, page_token, sync_token)
        access_token = access_token_for_user(user_id)

        url = "https://www.googleapis.com/calendar/v3/calendars/#{URI::encode(calendar)}/events?&access_token=#{access_token}"
        url = url + "&pageToken=#{page_token}" if not page_token.nil?
        url = url + "&syncToken=#{sync_token}" if not sync_token.nil?

        response = HTTParty.get(url)
        json = nil
        if response.code == 200
            json = JSON.parse(response.body)
        elsif response.code == 401 and response.message == 'Invalid Credentials'
            raise InvalidCredentialsException
        else
            Rails.logger.error "unable to list events for #{user_id}, url: #{url}"
            Rails.logger.error "list events response body: #{response.body}"
        end
        json
    end

    # sync

    def sync_calendar_for_user_helper(user_id)
        fetched_new = false
        begin
            fetched_new = (sync_calendar_list_for_user(user_id) and sync_events_for_user(user_id))
        rescue => err
            trace = err.backtrace.join("\n")
            Rails.logger.error "error when cloning calendar, message: #{err.message}\ntrace: #{trace}"
        end
        fetched_new
    end

    def sync_calendar_list_for_user(user_id)
        sync_token = calendar_list_sync_token_for_user(user_id)
        page_token = nil
        cals = []
        succeed = true
        fetched_new = false
        loop do
            start_time = Time.new

            json = list_calendars_list_for_user(user_id, page_token, sync_token)
            sync_token = json['nextSyncToken'] if json
            page_token = json['page_token'] if json
            cals += json['items'] if json and json['items']
            fetched_new ||= (cals.size > 0)

            # Rails.logger.info "cal list json: #{json}, page: #{page_token}, sync: #{sync_token}"

            succeed = false if not json
            break if not page_token or not succeed

            elapse = Time.new - start_time
            sleep(0.1 - elapse) if elapse < 0.1
        end
        save_calendar_for_user(user_id, cals)
        # TODO: as specified in google api document
        # check respond for 401 Gone to reset sync token
        update_calendar_list_sync_token_for_user(user_id, sync_token)

        push_notification(user_id, :cal_list_updated, 'calendar list updated') if fetched_new

        succeed
    end

    def sync_events_for_user(user_id)
        fetched_new = false
        all_calendars_for_user(user_id).each do |calendar_id, sync_token, calendar_name|
            fetched_new = (sync_events_for_user_with_calendar(user_id, calendar_id, sync_token) or fetched_new)
            # Rails.logger.info "events for cal name: #{calendar_name}, #{calendar_id}, #{sync_token}, fetched new: #{fetched_new}"
        end
        fetched_new
    end

    def sync_events_for_user_with_calendar(user_id, calendar_id, sync_token)
        # Rails.logger.info "call sync events for calendar #{calendar_id}, #{sync_token}"
        event_objects = []
        page_token = nil
        succeed = true
        loop do
            start_time = Time.new

            json = list_events_for_user(user_id, calendar_id, page_token, sync_token)
            page_token = json['nextPageToken'] if json
            sync_token = json['nextSyncToken'] if json
            event_objects += json['items'] if json and json['items']

            # Rails.logger.info "events for #{calendar_id}, json: #{json}, page: #{page_token}, sync: #{sync_token}" 

            succeed = false if not json
            break if not page_token or not succeed

            elapse = Time.new - start_time
            sleep(0.1 - elapse) if elapse < 0.1
        end
        save_events_for_user(user_id, calendar_id, event_objects)
        update_event_sync_token_for_calendar(calendar_id, user_id, sync_token)
        fetched_new = (succeed and event_objects.size > 0)
    end

    # save

    def save_calendar_for_user(user_id, cals)
        return if cals.empty?
        ActiveRecord::Base.connection_pool.with_connection do 
            cals.each do |cal|
                Cal.create_or_update_with_google_calendar(cal, user_id)
            end
        end
    end

    def save_events_for_user(user_id, calendar_id, events)
        return if events.empty?
        ActiveRecord::Base.connection_pool.with_connection do 
            events.each do |event|
                Event.create_or_update_with_gmail_event(event, user_id, calendar_id)
            end
        end
    end

    # helpers

    def start_sync_calendar_for_user(user_id)
        already_syncing = true
        @@mutex_lock ||= Mutex.new
        @@syncing_user_map ||= {}
        @@mutex_lock.synchronize do
            already_syncing = @@syncing_user_map.has_key?(user_id)
            @@syncing_user_map[user_id] = true
        end
        return already_syncing
    end

    def finish_sync_calendar_for_user(user_id)
        @@mutex_lock.synchronize do
            @@syncing_user_map.delete(user_id)
        end
    end

    def access_token_for_user(user_id)
        access_token = nil
        ActiveRecord::Base.connection_pool.with_connection do
            user = User.find(user_id)
            access_token = user.access_token
        end
        access_token
    end

    def all_calendars_for_user(user_id)
        result = []
        ActiveRecord::Base.connection_pool.with_connection do
            Cal.all.each do |cal|
                result << [cal.calendar_id, cal.sync_token, cal.name]
            end
        end
        # Rails.logger.info "all cals for user #{user_id}, result #{result}"
        result
    end

    def all_user_ids
        result = []
        ActiveRecord::Base.connection_pool.with_connection do
            if ActiveRecord::Base.connection.table_exists? 'users'
                User.all.each do |user|
                    result << user.id
                end
            end
        end
        result
    end

    def sync_in_background(&block)
        @sync_pool.process {
            block.call
            ActiveRecord::Base.connection.close
        }
    end

    def calendar_list_sync_token_for_user(user_id)
        token = nil
        ActiveRecord::Base.connection_pool.with_connection do 
            user = User.find(user_id)
            token = user.calendar_list_sync_token if user
        end
        token
    end

    def update_calendar_list_sync_token_for_user(user_id, sync_token)
        ActiveRecord::Base.connection_pool.with_connection do 
            user = User.find(user_id)
            if user
                user.calendar_list_sync_token = sync_token
                user.save
            end
        end
    end

    def update_event_sync_token_for_calendar(calendar_id, user_id, sync_token)
        ActiveRecord::Base.connection_pool.with_connection do 
            cal = Cal.where(:calendar_id => calendar_id).where(:user_id => user_id).first
            if cal
                cal.sync_token = sync_token
                cal.save
            end
        end
    end

    # notification
    def push_notification(user_id, event, data)
        begin
            WebsocketRails["#{user_id}"].trigger(event, data)
        rescue => err
            Rails.logger.error "error happened when trying to push notification: #{err.message}"
        end
    end
end