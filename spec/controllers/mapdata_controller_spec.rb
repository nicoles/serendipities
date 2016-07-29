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
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'renders some json' do
        pending
        get :show, start_date: start_date, end_date: end_date

        expect(response).to be_success
        parsed_body = JSON.parse(response.body)
      end
    end
  end

end
