require 'spec_helper'
describe 'sumologic_collector' do
  context 'with default values for all parameters' do
    it { should contain_class('sumologic_collector') }
  end
end
