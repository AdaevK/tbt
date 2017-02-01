require 'rails_helper'

feature 'success' do
  given(:courses) { File.read("spec/fixtures/courses.json") }

  before do
    FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"])
    FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: courses, status: ["200", "OK"])
  end

  scenario 'show courses index' do
    visit root_path

    expect(page).to have_content Oj.load(courses)[0]['name']
  end
end

feature 'fail' do
  given(:courses) { File.read("spec/fixtures/courses.json") }

  before do
    FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"])
    FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: courses, status: ["200", "OK"])
    visit root_path
    FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: courses, status: ["500", "Error"])
  end

  scenario 'show courses index' do
    visit root_path

    expect(page).to have_content 'В данный момент Teachbase'
    expect(page).to have_content Oj.load(courses)[0]['name']
  end

end

feature 'not authorize' do
  given(:courses) { File.read("spec/fixtures/courses.json") }

  before do
    FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: "{\"access_token\": \"7ff6c974b5299b1ecf83f4861ba35108832c34d43d3645f6f4268a0eef612193\", \"token_type\": \"bearer\", \"expires_in\": 7200, \"created_at\": 1485858898}", status: ["200", "OK"])
    FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: courses, status: ["200", "OK"])
    visit root_path
    FakeWeb.register_uri(:get, 'http://s1.teachbase.ru/endpoint/v1/course_sessions', body: courses, status: ["401", ""])
  end

  scenario 'show courses index' do
    visit root_path

    expect(page).to have_content 'Ошибка авторизации'
    expect(page).to_not have_content Oj.load(courses)[0]['name']
  end

end
