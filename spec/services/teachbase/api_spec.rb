require "rails_helper"

RSpec.describe Teachbase::Api do
  subject{ described_class }

  it_behaves_like 'raise_access_token',"{\"error\": \"invalid_request\", \"error_description\": \"translation missing: ru.doorkeeper.errors.messages.invalid_request\"}", 401
  it_behaves_like 'raise_access_token',"{\"error\": \"Internal Server Error\"}", 500

  context "success access token" do
    let(:access_token) { "7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193" }
    let(:body) { "{\"access_token\": \"#{access_token}\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}" }
    before{ FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: body, status: ["200", "OK"]) }

    its(:access_token){ is_expected.to eq access_token }
  end

  context "teachbase success course sessions" do
    let(:access_token) { "7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193" }
    let(:courses) { File.read("spec/fixtures/courses.json") }

    before do
      FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"#{access_token}\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"])
      FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: courses, status: ["200", "OK"])
    end

    its(:course_sessions) { is_expected.to eq({ body: Oj.load(courses), status_code: 200 }) }
  end

  context "teachbase fail course sesions" do
    let(:access_token) { "7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193" }

    before do
      FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"#{access_token}\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"])
      FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: "{\"error\": \"Internal Server Error\"}", status: ["500", "Internal Server Error"])
    end

    its(:course_sessions) { is_expected.to include({ status_code: 500 }) }
  end

  context "teachbase not authorize for course session" do

    before{ FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"error\": \"invalid_request\", \"error_description\": \"translation missing: ru.doorkeeper.errors.messages.invalid_request\"}", status: ["401", "Unauthorized"]) }

    its(:course_sessions) { is_expected.to eq({ body: nil, status_code: 401 }) }
  end

  context "if timeout for authorizion" do
    before do
      allow(described_class).to receive(:post).and_raise(Net::ReadTimeout)
    end

    its(:course_sessions) { is_expected.to eq({ body: nil, status_code: 503 }) }
  end

  context "if timeout for call method" do
    before do
      FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"])
      allow(described_class).to receive(:get).and_raise(Net::ReadTimeout)
    end

    its(:course_sessions) { is_expected.to eq({ body: nil, status_code: 503 }) }
  end
end
