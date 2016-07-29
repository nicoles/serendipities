require 'rails_helper'
include MovesResponseHelper

describe User do
  let(:user) { create(:user) }

  describe '#storyline_json_for_dates' do
    it 'gets existing moves data from the db'
    context 'with a valid api response' do
      date = Date.today
      let(:moves_response) { movesResponse(date) }

      before do
        allow(user.moves).to receive(:daily_storyline).and_return(moves_response)
      end
      it 'fetches moves data from the moves api' do
        json = user.storyline_json_for_dates(date, date)

        expect(user.storylines.find_by_story_date(date)).to_not be_nil
      end
      it 'turns moves data into useful geojson' do
        json = user.storyline_json_for_dates(date, date)

        expect(json.first[:type]).to eq("FeatureCollection")
        expect(json.first[:features].first[:properties][:type]).to_not be_nil
      end
    end

  end
end



