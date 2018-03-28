require 'spec_helper'
describe 'sumologic_collector' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('sumologic_collector') }
      it { is_expected.to contain_class('sumologic_collector::package') }
      it { is_expected.to contain_class('sumologic_collector::config') }
      it { is_expected.to contain_class('sumologic_collector::service') }
      it { is_expected.to contain_package('SumoCollector') }
      it { is_expected.to contain_service('collector') }
    end
  end
end
