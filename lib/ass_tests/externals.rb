module AssTests
  module Support
    def underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.to_s.gsub(/::/, '/')
#      word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    extend self
  end
  # Externals 1C dataprocessor and report
  module Externals
    require 'ass_launcher'
    class Processor
      attr_reader :path, :root
      def initialize(path, root)
        @path = AssLauncher::Support::Platforms.path(path.to_s).realpath
        @root = AssLauncher::Support::Platforms.path(root)
      end

      def exist?
        path.exist?
      end

      def manager
        :ExternalDataProcessors
      end

      def self.file_ext
        '.epf'
      end

      def file_ext
        self.class.file_ext
      end

      # It work only for :thick, :external
      def create(ole_connector, safe_mode = false)
        ole_connector.send(manager).create(connect(ole_connector, safe_mode))
      end

      def connect(ole_connector, safe_mode = false)
        fail "External not exist `#{path}'" unless exist?
        dd = ole_connector.newObject('BinaryData', path.win_string)
        link = ole_connector.PutToTempStorage(dd)
        ole_connector.send(manager).connect(link, name_for_ass, safe_mode)
      end

      def connected?(ole_connector)
        begin
          ole_connector.send(manager).create(name_for_ass)
        rescue WIN32OLERuntimeError
          return false
        end
        return true
      end

      # It work only :thick
      # @todo implemets form opts
      def get_form(ole_connector, name, safe_mode = false, **opts)
        #ole_connector.send(manager).getForm(path.win_string, name.to_s)
      #  create(ole_connector).getForm(name.to_s)
        ole_connector.getForm(form_full_name(connect(ole_connector, safe_mode),
                                             name))
      end

      def form_full_name(external_name, form_name)
        "#{manager.to_s.gsub(/s\z/,'')}.#{external_name}.Form.#{form_name}"
      end

      def name
        path.relative_path_from(root).to_s
      end

      def name_for_ass
        name.gsub('.','_').gsub(/(\/\\)/,'_')
      end
    end

    class Report < Processor
      def manager
        :ExternalReports
      end

      def self.file_ext
        '.erf'
      end
    end

    def self.root=(path)
      @root = path
    end

    def self.root
      fail 'Specify AssTests::Externals.root= path' unless @root
      @root
    end

    def self.externals
      r = {}
      Dir.glob(File.join(root,'**/*.{epf,erf}')) do |f|
        ext = new(f)
        r[ext.name] = ext
      end
      r
    end

    def self.get(name)
      externals[name] || fail(ArgumentError, "Uncknown external `#{name}'")
    end

    def self.new(path)
      klass(path).new(path, root)
    end

    KLASES = {'.epf' => Processor,
              '.erf' => Report
    }

    def self.klass(path)
      KLASES[File.extname(path).downcase] ||\
        fail(ArgumentError, "Uncknown external `#{path}'")
    end

    def external
      @external ||= AssTests::Externals.get(external_name)
    end
  end
end
