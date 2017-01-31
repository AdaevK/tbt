require "rails_helper"

RSpec.describe "routing" do
  it{ expect(get('/')).to route_to(action: 'index', controller: 'courses') }
end
