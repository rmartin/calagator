class SearchEngine::Sunspot::Event
  def self.add_searching_to(model)
    model.class_eval do
      # Return an Array of non-duplicate Event instances matching the search +query+..
      #
      # Options:
      # * :order => How to order the entries? Defaults to :score. Permitted values:
      #   * :score => Sort with most relevant matches first
      #   * :date => Sort by date
      #   * :name => Sort by event title
      #   * :title => same as :name
      #   * :venue => Sort by venue title
      # * :limit => Maximum number of entries to return. Defaults to +solr_search_matches+.
      # * :skip_old => Return old entries? Defaults to false.
      def self.search(query, opts={})
        skip_old = opts[:skip_old] == true
        limit = opts[:limit] || 50

        ordering = \
          case opts[:order].try(:to_sym)
          when :date, nil, ''
            [:start_time, :desc]
          when :venue, :location
            [:venue_title_for_solr, :asc]
          when :name, :title
            [:title, :asc]
          else
            [:score, :desc]
          end

        # Sunspot 1.2.1 seems to ignore pagination, e.g.:
        ### paginate(:page => 1, :per_page => 100)
        Sunspot.config.pagination.default_per_page = 50

        searcher = Sunspot.search(self) do
          keywords(query) do
            boost_fields :title => 3.0
            boost_fields :tag_list => 3.0
          end

          order_by(*ordering)

          with(:duplicate_for_solr, false)

          if skip_old
            with(:start_time).greater_than(Date.yesterday.to_time)
          end
        end
        return searcher.results
      end

      def venue_title_for_solr
        return self.venue.try(:title)
      end

      # Do this last to prevent Sunspot from taking over our ::search method.
      unless RAILS_ENV == 'test'
        # Why aren't these loaded by default!?
        include Sunspot::Rails::Searchable unless defined?(self.solr_search)
        Sunspot::Adapters::InstanceAdapter.register(Sunspot::Rails::Adapters::ActiveRecordInstanceAdapter, self)
        Sunspot::Adapters::DataAccessor.register(Sunspot::Rails::Adapters::ActiveRecordDataAccessor, self)

        searchable do
          text :title, :default_boost => 3.0
          string :title

          text :description

          text :tag_list, :default_boost => 3.0

          text :url

          time :start_time
          time :end_time

          text :venue_title_for_solr
          string :venue_title_for_solr

          boolean :duplicate_for_solr do |record|
            record.duplicate_of_id.present?
          end
        end
      end
    end
  end
end