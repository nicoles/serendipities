class MapdataController < ApplicationController

  def show
    start_date = params[:start_date] ||= 4.days.ago.to_date
    end_date = params[:end_date] ||= 4.days.ago.to_date
    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)
    @moves_storylines = []
    start_date.upto(end_date) do |date|
      if !current_user.storylines.find_by_story_date(date).blank?
        @moves_storylines << JSON[current_user.storylines.find_by_story_date(date).moves_data]
      else
        moves_storyline = current_user.moves.daily_storyline(date, :trackPoints => true).first
        current_user.storylines.create(:story_date=> date, :moves_data => moves_storyline)
        @moves_storylines << JSON[moves_storyline]
      end
    end
    moves_storylines = {dates: @moves_storylines}
    render json: moves_storylines
  end

end
