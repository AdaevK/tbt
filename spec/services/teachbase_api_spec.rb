require "rails_helper"

RSpec.describe TeachbaseApi do
  context "teachbase fail auth" do
    before{ FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"error\": \"invalid_request\", \"error_description\": \"translation missing: ru.doorkeeper.errors.messages.invalid_request\"}", status: ["401", "Unauthorized"]) }

    its(:authorize){ is_expected.to be_falsy }
    context 'after call authorize' do
      before { subject.send(:authorize) }

      its(:access_token){ is_expected.to be_nil }
      its(:status_code){ is_expected.to eq 401 }
    end
  end

  context "taechbase broken" do
    before{ FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"error\": \"Internal Server Error\"}", status: ["500", "Internal Server Error"]) }

    its(:authorize){ is_expected.to be_falsy }
    context 'after call authorize' do
      before { subject.send(:authorize) }

      its(:access_token){ is_expected.to be_nil }
      its(:status_code){ is_expected.to eq 500 }
    end
  end

  context "teachbase success auth" do
    let(:access_token) { "7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193" }
    before{ FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"#{access_token}\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"]) }

    its(:authorize) { is_expected.to be_truthy }
    context "after call authorize" do
      before { subject.send(:authorize) }

      its(:access_token){ is_expected.to eq access_token }
      its(:status_code){ is_expected.to eq 200 }
    end
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
end
