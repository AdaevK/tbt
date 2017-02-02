require 'rails_helper'

RSpec.describe CoursesForm do
  let(:info){ TeachbaseCourses.new }

  its(:page){ is_expected.to eq 1 }
  it{ is_expected.to respond_to :get }

  describe 'success get' do
    let(:courses) { Oj.load(File.read("spec/fixtures/courses.json")) }
    let(:new_courses) { courses.push({ id: 10 }) }

    before do
      info
      info.set_body(courses)
      class_double(Teachbase::Api, course_sessions: { body: new_courses, status_code: 200 }).as_stubbed_const
      subject.get
    end

    it{ expect(subject.items.count).to eq new_courses.count }
    its(:message){ is_expected.to be_nil }
    it{ expect(info.body.value).to eq Oj.dump(new_courses) }

    context 'unless first page' do
      subject{ CoursesForm.new(page: 2) }

      it{ expect(subject.items.count).to eq new_courses.count }
      it{ expect(info.body.value).to_not eq Oj.dump(new_courses) }
    end
  end

  describe 'failer get' do
    let(:courses) { Oj.load(File.read("spec/fixtures/courses.json")) }

    context 'if TeachbaseCourses body not empty' do
      before do
        info
        info.set_body(courses)
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 500 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items.count).to eq courses.count }
      its(:message){ is_expected.to eq I18n.t('courses_form.messages.response_invalid', date: info.get_updated_at.strftime("%d.%m.%Y %H:%M")) }
    end

    context 'if TeachbaseCourses body empty' do
      before do
        info
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 500 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items).to be_nil }
    end

    context 'if server broken' do
      let(:hours) { 10.hours }
      before do
        tb = TeachbaseCourses.new
        tb.set_body(courses)
        tb.updated_at = DateTime.now - hours
        tb.server_broken = true
        info
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 200 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items.count).to eq courses.count }
      its(:message){ is_expected.to eq I18n.t('courses_form.messages.server_broken', hours: (hours / 3600).round) }
    end

    context 'if not authenticate' do
      before do
        info
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 401 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items).to be_nil }
      its(:message){ is_expected.to eq I18n.t('courses_form.messages.invalid_auth') }
    end
  end
end
