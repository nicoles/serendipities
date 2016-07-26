require 'rails_helper'
include AuthenticationHelper

describe MapdataController do
  describe '#show' do
    let(:start_date) { 4.days.ago.to_date.to_s }
    let(:end_date) { 4.days.ago.to_date.to_s }

    context 'when not signed in' do
      it 'redirects to login' do
        get :show, start_date: start_date, end_date: end_date

        expect(response).to redirect_to('/auth/moves')
      end
    end

    context 'when signed in' do
      before do
        # get signed in. who knows
        user = User.last
        sign_in user
      end

      it 'returns geojson for a pair of dates' do
        get :show, start_date: start_date, end_date: end_date

        expect(response).to be_success
        parsed_body = JSON.parse(response.body)
      end
    end
  end

end
