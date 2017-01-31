require "rails_helper"

RSpec.describe CoursesController, type: :controller do
  context "GET index" do
    before { get :index }

    it{ expect(response).to have_http_status :ok }
    it{ expect(response).to render_template :index }
  end
end
