RSpec.shared_examples 'raise_access_token' do |body, code|
  describe "for #{code} error" do
    before{ FakeWeb.register_uri(:post, 'http://s1.teachbase.ru/oauth/token', body: body, status: [code, nil]) }

    it{ expect{ subject.send(:access_token) }.to raise_error(Teachbase::AuthorizeError){ |e|
      expect(e.status_code).to eq code
      expect(e.body).to eq body
    } }
  end
end
