require 'spec_helper'

describe OmniAuth::Strategies::Line do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}) }

  subject do
    args = ['channel_id', 'secret', @options || {}].compact
    OmniAuth::Strategies::Line.new(nil, *args).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  describe 'client options' do
    it 'should have correct name' do
      expect(subject.options.name).to eq('line')
    end

    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://access.line.me')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('/oauth2/v2.1/authorize')
    end

    it 'should have correct token url' do
      expect(subject.options.client_options.token_url).to eq('/oauth2/v2.1/token')
    end
  end

  describe 'uid' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'should returns the uid' do
      expect(subject.uid).to eq(raw_info_hash['userId'])
    end
  end

  describe 'info' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'should returns the name' do
      expect(subject.info[:name]).to eq(raw_info_hash['displayName'])
    end

    it 'should returns the image' do
      expect(subject.info[:image]).to eq(raw_info_hash['pictureUrl'])
    end

    it 'should returns the description' do
      expect(subject.info[:description]).to eq(raw_info_hash['statusMessage'])
    end

    it 'returns nil for email when id_token is not present' do
      expect(subject.info[:email]).to be_nil
    end

    context 'when id_token is present in access_token' do
      let(:response) { double('Response', body: '{"email":"foo@example.com"}') }
      let(:access_token) do
        double('AccessToken', params: { 'id_token' => 'dummy_id_token' })
      end

      before do
        allow(subject).to receive(:access_token).and_return(access_token)
        allow(access_token).to receive(:post).with(
          'oauth2/v2.1/verify',
          body: { id_token: 'dummy_id_token', client_id: 'channel_id' }
        ).and_return(response)
      end

      it 'fetches and returns the email via verify endpoint' do
        expect(subject.info[:email]).to eq('foo@example.com')
      end
    end
  end

  describe 'extra' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'includes raw_info' do
      expect(subject.extra).to eq({ 'raw_info' => raw_info_hash })
    end
  end

  describe 'request_phase' do
    context 'with no request params set' do
      before do
        allow(subject).to receive(:request).and_return(
          double('Request', {:params => {}})
        )
        allow(subject).to receive(:request_phase).and_return(:whatever)
      end

      it 'should not break' do
        expect { subject.request_phase }.not_to raise_error
      end
    end

    it 'resets client_options[:site] to https://access.line.me even after callback_phase' do
      subject.options[:client_options][:site] = 'https://api.line.me'
      allow(subject).to receive(:redirect)
      allow(subject).to receive(:authorize_params).and_return({})
      allow(subject).to receive(:callback_url).and_return('https://example.com/auth/line/callback')

      subject.request_phase
      expect(subject.options.client_options.site).to eq('https://access.line.me')
    end
  end

  describe '#callback_url' do
    it 'should return callback url with script_name' do
      base_url = 'https://example.com'
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name) { '/v1' }
      expect(subject.send(:callback_url)).to eq "#{base_url}/v1/auth/line/callback"
    end

    it 'should prefer options[:callback_url] when configured' do
      subject.options[:callback_url] = 'https://custom.example.com/callback'
      expect(subject.send(:callback_url)).to eq 'https://custom.example.com/callback'
    end
  end

end

private

def raw_info_hash
  {
    'userId'        => 'hoge',
    'displayName'   => 'Foo Bar',
    'pictureUrl'    => 'http://xxx.com/aaa.jpg',
    'statusMessage' => 'Developer'
  }
end
