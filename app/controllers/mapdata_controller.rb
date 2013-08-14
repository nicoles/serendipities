class MapdataController < ApplicationController

  def show
    # params[:date] ||= Date.today.to_s
    params[:date] ||= 4.days.ago.to_date.to_s
    data = current_user.moves.daily_storyline(params[:date], :trackPoints => true).first
    render json: data
  end

end
