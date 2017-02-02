require "rails_helper"

RSpec.describe TeachbaseCourses do
  context 'filling data' do
    let(:date) { DateTime.now }
    let(:params) { { id: '1', body: "Test", status: 200, updated_at: date } }
    subject{ TeachbaseCourses.new params }

    its(:id) { is_expected.to eq params[:id] }
    its(:body) { is_expected.to eq params[:body].to_s }
    its(:status) { is_expected.to eq params[:status].to_s }
    its(:updated_at) { is_expected.to eq params[:updated_at].to_s }
  end

  context 'blank data' do
    its(:id) { is_expected.to eq ENV['CLIENT_KEY'] }
    its(:body) { is_expected.to be_nil }
    its(:status) { is_expected.to be_nil }
    its(:updated_at) { is_expected.to be_nil }
  end

  describe 'method get' do
    let(:courses) { Oj.load(File.read("spec/fixtures/courses.json")) }
    let(:new_courses) { courses.push({ "id" => 10 }) }

    before do
      subject.set_body(courses)
      class_double(Teachbase::Api, course_sessions: request_data).as_stubbed_const
    end

    context 'if response success' do
      let(:request_data){ { body: new_courses, status_code: 200 } }

      it{ expect(subject.get.count).to eq new_courses.count }

      describe 'states after call' do
        before { subject.get }

        it{ expect(subject.body.value).to eq Oj.dump(new_courses) }

        its(:invalid_authentication?){ is_expected.to be_falsy }
        its(:response_invalid?){ is_expected.to be_falsy }
        its(:server_broken?){ is_expected.to be_falsy }
      end
    end

    context 'if response fail' do
      let(:request_data){ { body: nil, status_code: 500 } }

      it{ expect(subject.get.count).to eq courses.count }

      describe 'states after call' do
        before { subject.get }

        it{ expect(subject.server_broken.value).to eq "true" }

        its(:invalid_authentication?){ is_expected.to be_falsy }
        its(:response_invalid?){ is_expected.to be_truthy }
        its(:server_broken?){ is_expected.to be_falsy }
      end
    end

    context 'if servese broken' do
      subject{ TeachbaseCourses.new.server_broken = true; TeachbaseCourses.new }

      let(:request_data){ { body: nil, status_code: 500 } }

      it{ expect(subject.get.count).to eq courses.count }

      describe 'states after call' do
        before { subject.get }

        its(:invalid_authentication?){ is_expected.to be_falsy }
        its(:response_invalid?){ is_expected.to be_falsy }
        its(:server_broken?){ is_expected.to be_truthy }
      end
    end

    context 'not authorize' do
      let(:request_data){ { body: nil, status_code: 401 } }

      its(:get){ is_expected.to be_nil }

      describe 'states after call' do
        before { subject.get }

        its(:invalid_authentication?){ is_expected.to be_truthy }
        its(:response_invalid?){ is_expected.to be_falsy }
        its(:server_broken?){ is_expected.to be_falsy }
      end
    end
  end
end
