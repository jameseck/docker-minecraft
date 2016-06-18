require 'serverspec'
require "docker"

CONTAINER_START_SLEEP = 60

describe "Dockerfile" do
  before(:all) do
    puts "Building image"
    @image = Docker::Image.build_from_dir('.')
    puts "Finished building image"

    set :backend, :docker
    #set :docker_image, @image.id
  end

  describe 'Dockerfile#running' do
    before(:all) do
      @container = Docker::Container.create(
        'Image'      => @image.id,
      }

      ret = @container.start

      ready_regex = /\[Server thread\/INFO\]: Done \(([0-9\.s]+)\)\! For help, type \"help\" or \"\?\"/
      counter=0
      while counter < CONTAINER_START_SLEEP do
        match = @container.logs({ :stdout => true }).split("\n").grep(ready_regex)
        unless match.empty? then
          puts "Found minecraft server ready match"
          break
        end
        puts "Sleeping for 5 seconds while minecraft starts up... #{counter}/#{CONTAINER_START_SLEEP}"
        sleep 5
        counter += 5
      end
      if counter >= CONTAINER_START_SLEEP then
        puts "TIMEOUT during startup - leaving container for debugging"
        @container.kill
        exit 1
      end

      puts @container.logs({ :stdout => true, :stderr => true })

      set :docker_container, @container.id
    end

    it "installs the right version of CentOS" do
      expect(os_version).to match(/^CentOS Linux release 7/)
    end
    def os_version
      command("cat /etc/redhat-release").stdout
    end

    describe process('java') do
      it { should be_running }
    end

    describe port(25565) do
      it { should be_listening }
    end

    after(:all) do
      @container.kill
      @container.delete(:force => true)
    end
  end
end
