require 'spec_helper'
describe 'artifactory_staging' do

  context 'with defaults for all parameters' do
    it { should contain_class('artifactory_staging') }
  end
end
