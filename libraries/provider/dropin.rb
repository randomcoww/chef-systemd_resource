class ChefSystemdResource
  class Provider
    class Dropin < Chef::Provider
      include SystemdHelper

      provides :systemd_resource_dropin, os: "linux"

      def load_current_resource
        @current_resource = ChefSystemdResource::Resource::Dropin.new(new_resource.name)

        current_resource.exists(::File.exist?(new_resource.path))

        if current_resource.exists
          current_resource.content(::File.read(new_resource.path))
        else
          current_resource.content('')
        end

        current_resource
      end

      def action_create
        converge_by("Create systemd dropin: #{new_resource.name}") do
          create_base_path
          dropin_config.run_action(:create)
          systemd_daemon_reload
        end if !current_resource.exists || current_resource.content != new_resource.content
      end


      private

      def create_base_path
        Chef::Resource::Directory.new(::File.dirname(new_resource.path), run_context).tap do |r|
          r.recursive true
        end.run_action(:create_if_missing)
      end

      def dropin_config
        @dropin_config ||= Chef::Resource::File.new(new_resource.path, run_context).tap do |r|
          r.path new_resource.path
          r.content new_resource.content
        end
      end
    end
  end
end
