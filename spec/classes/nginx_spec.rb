require 'spec_helper'

describe 'nginx' do
  it { is_expected.to compile }
  it { is_expected.to contain_class('nginx') }
end
