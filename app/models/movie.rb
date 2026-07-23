class Movie < ApplicationRecord
  RATINGS = %w[G PG PG-13 R].freeze
  SORTABLE_COLUMNS = %w[title release_date].freeze

  def self.all_ratings
    RATINGS
  end

  def self.with_ratings(ratings_list, sort_by = "title")
    movies =
      if ratings_list.blank?
        all
      else
        where(rating: ratings_list)
      end

    sort_column =
      if SORTABLE_COLUMNS.include?(sort_by)
        sort_by
      else
        "title"
      end

    movies.order(sort_column)
  end
end
