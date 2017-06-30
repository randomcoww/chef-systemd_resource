class ChefSystemdResource
  class Resource
    class Dropin < Chef::Resource
      include Systemd

      resource_name :systemd_resource_dropin

      default_action :create
      allowed_actions :create, :delete

      property :exists, [TrueClass, FalseClass]
      property :service, String
      property :config, Hash
      property :content, String, default: lazy { to_conf }
      property :path, String, desired_state: false,
                              default: lazy { ::File.join(Systemd::BASE_PATH, "#{service}.d", "#{name}.conf") }

      private

      def to_conf
        systemd_generate_config(config)
      end
    end
  end
end
