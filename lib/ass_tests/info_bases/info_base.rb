module AssTests
  module InfoBases
    require 'ass_maintainer/info_base'
    class InfoBase < AssMaintainer::InfoBase
      OPTIONS = {
        template: nil,
        fixtures: nil,
      }

      OPTIONS.each_key do |key|
        define_method key do
          options[key]
        end
      end

      def self.ALL_OPTIONS()
        AssMaintainer::InfoBase::OPTIONS.merge OPTIONS
      end

      def initialize(name, connection_string, read_only = true, **options)
        super name, connection_string, read_only, **OPTIONS.merge(options)
      end

      attr_reader :template_loaded
      alias_method :template_loaded?, :template_loaded

      attr_reader :fixtures_loaded
      alias_method :fixtures_loaded?, :fixtures_loaded

      def built?
        exists? && (template_loaded? || false) && (fixtures_loaded? || false)
      end

      def make_infobase!
        super
        load_template!
        load_fixtures!
        self
      end
      private :make_infobase!

      def load_template!
        fail AssMaintainer::InfoBase::MethodDenied, :load_template! if\
          read_only?
        load_template
        @template_loaded = true
      end

      def load_fixtures!
        fail AssMaintainer::InfoBase::MethodDenied, :load_fixtures! if\
          read_only?
        fixtures.execute(self) if fixtures
        @fixtures_loaded = true
      end

      def erase_data!
        fail AssMaintainer::InfoBase::MethodDenied, :erase_data! if read_only?
        designer do
          eraseData
        end.run.wait.result.verify!
        true
      end

      def reload_fixtures!
        erase_data!
        load_fixtures!
      end

      # @api private
      def template_type
        return :cf if template_cf?
        return :dt if template_dt?
        return :src if template_src?
        template.to_s
      end

      # @api private
      def file_template?(ext)
        template.to_s =~ %r{\.#{ext}\z} && File.file?(template.to_s)
      end

      # @api private
      def template_cf?
        file_template? 'cf'
      end

      # @api private
      def template_dt?
        file_template? 'dt'
      end

      # @api private
      def template_src?
        template.respond_to?(:path) &&\
          File.file?(File.join(src_path, 'Configuration.xml'))
      end

      def src_path
        template.path.to_s
      end
      private :src_path

      # @api private
      def load_template
        return unless template
        case template_type
        when :cf then load_cf
        when :dt then load_dt
        when :src then load_src
        else
          fail "Invalid template: #{template}"
        end
        template_type
      end

      # @api private
      def load_src
        cfg.load_xml(src_path) && db_cfg.update
      end

      # @api private
      def load_dt
        restore!(template)
      end

      # @api private
      def load_cf
        cfg.load(template) && db_cfg.update
      end
    end
  end
end
