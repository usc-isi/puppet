require 'spec_helper'
describe 'swift::repo::milestone' do

  describe 'when apt is not included' do
    it 'should raise an error' do
      expect do
        subject
      end.should raise_error(Puppet::Error)
    end
  end

  describe 'when apt is included' do
    let :pre_condition do
      'include apt'
    end
    it { should contain_apt__ppa('ppa:swift-core/milestone') }
  end
end
