require 'spec_helper'

require 'picasso/remote/service_directory'

describe Picasso::Remote::ServiceDirectory do

  subject(:service_directory) { Picasso::Remote::ServiceDirectory }

  let(:code_name) { 'vpos' }
  let(:version) { '0.1' }
  let(:doc_url) { 'some_url/doc' }
  let(:api_url) { 'some_url/api' }

  before do
    Picasso::Remote::ServiceDirectory.stub(:service_configuration => { "v#{version}" => {
      'doc_url' => doc_url, 'api_url' => api_url }
    })
  end

  describe '.get_service_definition' do

    let(:service_definition){ double(:service_definition)}

    context 'when a file url' do
      let(:doc_url) { 'file://path/to/doc' }

      before do
        Angus::SDoc::DefinitionsReader.stub(:service_definition => service_definition)
      end

      it 'builds the service definition from the path' do
        Angus::SDoc::DefinitionsReader.should_receive(
          :service_definition
        ).with('path/to/doc')

        service_directory.get_service_definition(code_name, version)
      end

      it 'returns the service definition' do
        service_directory.get_service_definition(code_name, version).should eq(service_definition)
      end
    end

    context 'when a remote url' do
      let(:doc_url) { 'some_url/doc' }
      let(:definition_hash) { {} }

      before do
        service_directory.stub(:fetch_remote_service_definition => definition_hash)
        Angus::SDoc::DefinitionsReader.stub(:build_service_definition => service_definition)
      end

      it 'gets the definition hash from the remote service' do
        service_directory.should_receive(:fetch_remote_service_definition).with(
          doc_url
        ).and_return(definition_hash)

        service_directory.get_service_definition(code_name, version)
      end

      it 'builds the service definition from the definition hash' do
        Angus::SDoc::DefinitionsReader.should_receive(
          :build_service_definition
        ).with(definition_hash)

        service_directory.get_service_definition(code_name, version)
      end

      it 'returns the service definition' do
        service_directory.get_service_definition(code_name, version).should eq(service_definition)
      end
    end

  end

end