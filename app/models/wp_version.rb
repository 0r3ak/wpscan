# frozen_string_literal: true

module WPScan
  module Model
    # WP Version
    class WpVersion < CMSScanner::Model::Version
      include Vulnerable

      def initialize(number, opts = {})
        raise Error::InvalidWordPressVersion unless WpVersion.valid?(number.to_s)

        super(number, opts)
      end

      # @param [ String ] number
      #
      # @return [ Boolean ] true if the number is a valid WP version, false otherwise
      def self.valid?(number)
        all.include?(number)
      end

      # @return [ Array<String> ] All the version numbers
      def self.all
        return @all_numbers if @all_numbers

        @all_numbers = []

        DB::Fingerprints.wp_fingerprints.each_value do |fp|
          @all_numbers << fp.values
        end

        # @all_numbers.flatten.uniq.sort! {} doesn't produce the same result here.
        @all_numbers.flatten!
        @all_numbers.uniq!
        @all_numbers.sort! { |a, b| Gem::Version.new(b) <=> Gem::Version.new(a) }
      end

      # @return [ JSON ]
      def metadata
        @metadata ||= DB::Version.metadata_at(number)
      end

      # @return [ Array<Vulnerability> ]
      def vulnerabilities
        return @vulnerabilities if @vulnerabilities

        @vulnerabilities = []

        # TODO get them from API
        #[*db_data['vulnerabilities']].each do |json_vuln|
        #  @vulnerabilities << Vulnerability.load_from_json(json_vuln)
        #end

        @vulnerabilities
      end

      # @return [ String ]
      def release_date
        @release_date ||= metadata['release_date'] || 'Unknown'
      end

      # @return [ String ]
      def status
        @status ||= metadata['status'] || 'Unknown'
      end
    end
  end
end
