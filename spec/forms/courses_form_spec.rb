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
    it{ expect(subject.errors.messages.empty?).to be_truthy }
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
      let(:error_message) { I18n.t('activemodel.errors.models.courses_form.attributes.base.response_invalid_with_date', date: info.get_updated_at.strftime("%d.%m.%Y %H:%M")) }
      before do
        info
        info.set_body(courses)
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 500 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items.count).to eq courses.count }
      it{ expect(subject.errors.messages[:base]).to be_include(error_message) }
    end

    context 'if TeachbaseCourses body empty' do
      before do
        info
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 500 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items).to be_nil }
      it_behaves_like "check_error_message", :base, I18n.t('activemodel.errors.models.courses_form.attributes.base.response_invalid')
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
      it_behaves_like "check_error_message", :base, I18n.t('activemodel.errors.models.courses_form.attributes.base.server_broken', hours: (10.hours / 3600).round)
    end

    context 'if not authenticate' do
      before do
        info
        class_double(Teachbase::Api, course_sessions: { body: nil, status_code: 401 }).as_stubbed_const
        subject.get
      end

      it{ expect(subject.items).to be_nil }
      it_behaves_like "check_error_message", :base, I18n.t('activemodel.errors.models.courses_form.attributes.base.invalid_auth')
    end
  end
end
