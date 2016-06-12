require 'serverspec'
require "docker"

describe "Dockerfile" do
  before(:all) do
    image = Docker::Image.build_from_dir('.')

    set :backend, :docker
    set :docker_image, image.id
  end

  it "installs the right version of CentOS" do
    expect(os_version).to match(/^CentOS Linux release 7/)
  end

  describe process('java') do
    it { should be_running }
  end

  describe port(25565) do
    it { should be_listening }
  end

  def os_version
    command("cat /etc/redhat-release").stdout
  end
end
