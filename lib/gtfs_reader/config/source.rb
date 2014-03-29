require_relative 'feed_definition'
require_relative 'defaults/gtfs_feed_definition'
require_relative '../feed_handler'
require_relative '../bulk_feed_handler'

module GtfsReader
  module Config
    # A single source of GTFS data
    class Source
      attr_reader :name

      def initialize(name)
        @name = name
        @feed_definition = Config::Defaults::FEED_DEFINITION
        @feed_handler = FeedHandler.new {}
      end

      #@param u [String] if given, will be used as the URL for this source
      #@return [String] the URL this source's ZIP file
      def url(u=nil)
        @url = u if u.present?
        @url
      end

      def feed_definition(&block)
        if block_given?
          @feed_definition = FeedDefinition.new.tap do |feed|
            feed.instance_exec feed, &block
          end
        end

        @feed_definition
      end

      def handlers(opts={}, &block)
        if block_given?
          opts = opts.reverse_merge bulk: nil
          @feed_handler =
            if opts[:bulk]
              BulkFeedHandler.new opts[:bulk], &block
            else
              FeedHandler.new &block
            end
        end
        @feed_handler
      end
    end
  end
end
