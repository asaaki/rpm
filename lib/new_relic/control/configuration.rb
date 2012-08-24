module NewRelic
  class Control
    # used to contain methods to look up settings from the
    # configuration located in newrelic.yml
    module Configuration
      def settings
        unless @settings
          @settings = (@yaml && @yaml[env]) || {}
          # At the time we bind the settings, we also need to run this little piece
          # of magic which allows someone to augment the id with the app name, necessary
          if Agent.config['multi_homed'] && Agent.config.app_names.size > 0
            if @local_env.dispatcher_instance_id
              @local_env.dispatcher_instance_id << ":#{Agent.config.app_names.first}"
            else
              @local_env.dispatcher_instance_id = Agent.config.app_names.first
            end
          end

        end
        @settings
      end

      # Merge the given options into the config options.
      # They might be a nested hash
      def merge_options(options, hash=self)
        options.each do |key, val|
          case
          when key == :config then next
          when val.is_a?(Hash)
            merge_options(val, hash[key.to_s] ||= {})
          when val.nil?
            hash.delete(key.to_s)
          else
            hash[key.to_s] = val
          end
        end
      end

      def [](key)
        fetch(key)
      end

      def []=(key, value)
        settings[key] = value
      end

      def fetch(key, default=nil)
        settings.fetch(key, default)
      end

      def apdex_t
        Agent.config[:apdex_t]
      end
    end
    include Configuration
  end
end
