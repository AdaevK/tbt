RSpec.shared_examples 'check_error_message' do |field, message|
  describe "error message for #{field}" do
    it{ expect(subject.errors.messages[field]).to be_include(message) }
  end
end
