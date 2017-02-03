class MapdataController < ApplicationController
  def show
    start_date =           params[:start_date] ||= 4.days.ago.to_date
    end_date =             params[:end_date] ||= 4.days.ago.to_date
    start_date =           Date.parse(start_date)
    end_date =             Date.parse(end_date)

    render json: current_user.storyline_json_for_dates(start_date, end_date, false)
    # send a pile of json to the frontend
  end
end
