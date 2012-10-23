require 'spec_helper'

describe 'The S3itch App' do
  let(:app) {
    Fog.mock!
    Fog.credentials = {
      :aws_access_key_id => "key",
      :aws_secret_access_key => "secret",
      :region => "us-east-1"
    }
    connection = Fog::Storage.new(:provider => 'AWS')

    S3itchApp.any_instance.stub(:bucket).and_return(connection.directories.create(:key => ENV['S3_BUCKET']))

    S3itchApp
  }

  let(:file_path) {
    File.expand_path("../../support/image.png", __FILE__)
  }

  let(:uploaded_file) {
    Rack::Test::UploadedFile.new(file_path, "image/jpeg")
  }

  it "says OK" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'OK'
  end

  it "uploads files from Skitch to S3" do
    put '/title-20121023-123456.png', "file" => uploaded_file
    last_response.status.should == 201
  end
  
  it "uploads files from TweetBot to S3" do
    post '/tweetbot/', "media" => { "tempfile" => uploaded_file.path, "filename" => "image.png", "type" => "image/png" }
  end
end