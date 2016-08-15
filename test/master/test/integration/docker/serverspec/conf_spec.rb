require 'serverspec'
set :backend, :exec

describe file('/etc/salt/master.d/10-roots.conf') do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content_as_yaml) do
    should eq(
      'file_roots' => {'base' => ['/srv/spm/salt/']},
      'pillar_roots' => {'base' => ['/srv/spm/pillar/']}
    )
  end
end

describe file('/etc/salt/master.d/20-tops.conf') do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content_as_yaml) do
    should eq(
      'state_top' => 'sp/glue/tops/top.sls'
    )
  end
end

describe file('/etc/salt/spm.repos.d/spm.repo') do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content_as_yaml) do
    should eq(
      'internal' => {'url' => 'http://localhost/spm/internal'}
    )
  end
end
