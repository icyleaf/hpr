# frozen_string_literal: true

require File.expand_path '../spec_helper.rb', __dir__

describe 'Hpr Web Application' do
  it 'should allow accessing the api layer' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq JSON.dump(message: 'Welcome to hpr api layer')
  end

  it 'should allow accessing the info api' do
    get '/info'
    expect(last_response).to be_ok
  end

  it 'should allow accessing the config api' do
    get '/config'
    expect(last_response).to be_ok
  end
end
