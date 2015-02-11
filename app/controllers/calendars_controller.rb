class CalendarsController < ApplicationController

    def events
        Rails.logger.info "params #{params}"
        @cal = Cal.find(params[:calendar_id])
        if @cal.nil?
            error_msg = { :error_code => 500, :error_message => "calendar not found" }
            render json: JSON.generate(error_msg)
        else
            events = []
            @cal.events.where("start_time > ?", Time.at(params[:start].to_i)).where("end_time < ?", Time.at(params[:end].to_i)).each do |evt|
                events << evt.json_presentation
            end
            result = JSON.generate({ :events => events })
            render json: result
        end
    end
end
