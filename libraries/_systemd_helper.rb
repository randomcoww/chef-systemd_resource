module SystemdHelper

  include Chef::Mixin::Which
  include Chef::Mixin::ShellOut

  BASE_PATH ||= "/etc/systemd/system"

  def systemd_daemon_reload
    shell_out_with_systems_locale!("#{systemctl_path} daemon-reload")
  end

  def systemctl_path
    @systemctl_path ||= which("systemctl")
  end


  class ConfigGenerator
    def self.generate_from_hash(c)
      g = new
      g.ini_sections(c).join($/)
    end

    def ini_sections(c, res=[])
      c.each_pair do |k, v|
        case v
        when Array
          v.each do |j|
            ini_sections({k => j}, res)
          end

        when Hash
          res << "[#{k}]"
          ini_options(v, res)
          res << ""
        end
      end
      res
    end

    def ini_options(c, res=[])
      c.each_pair do |k, v|
        case v
        when Array
          v.each do |j|
            ini_options({k => j}, res)
          end

        when Hash
          next

        when NilClass
          res << k

        else
          res << [k, v].join('=')
        end
      end
    end
  end
end
