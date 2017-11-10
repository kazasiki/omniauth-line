require 'spec_helper'

describe OmniAuth::Strategies::Line do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}) }

  subject do
    args = ['channel_id', 'secret', @options || {}].compact
    OmniAuth::Strategies::Line.new(*args).tap do |strategy|
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
      expect(subject.uid).to eq(raw_info_hash['mid'])
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
  end

end

private

def raw_info_hash
  {
    'uid'           => 'hoge',
    'displayName'   => 'Foo Bar',
    'pictureUrl'    => 'http://xxx.com/aaa.jpg',
    'statusMessage' => 'Developer'
  }
end
