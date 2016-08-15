require 'serverspec'
set :backend, :exec

describe file('/root/test/file.txt') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should eq("Salt Master test\n") }
end

describe file('/root/test/secret.txt') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should eq("Don't tell anyone!\n") }
end
