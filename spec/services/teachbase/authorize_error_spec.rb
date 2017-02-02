require "rails_helper"

RSpec.describe Teachbase::AuthorizeError do
  let(:body) { 'Test error' }
  let(:status_code) { 500 }
  subject{ described_class.new(body, status_code) }

  its(:body) { is_expected.to eq body }
  its(:status_code) { is_expected.to eq status_code }
end
