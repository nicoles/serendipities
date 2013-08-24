class MapdataController < ApplicationController

  def show
    # params[:date] ||= Date.today.to_s
    params[:date] ||= 4.days.ago.to_date.to_s
    if !current_user.storylines.find_by_story_date(params[:date]).blank?
      data = current_user.storylines.find_by_story_date(params[:date]).moves_data
    else
      data = current_user.moves.daily_storyline(params[:date], :trackPoints => true).first
      current_user.storylines.create(:story_date=> params[:date], :moves_data => data)
    end
    render json: data
  end

end
