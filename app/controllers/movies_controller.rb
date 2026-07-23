class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings

    form_submitted = params[:settings_submitted] == "1"
    new_ratings_supplied = params[:ratings].present?
    new_sort_supplied = params[:sort_by].present?

    settings_supplied =
      form_submitted || new_ratings_supplied || new_sort_supplied

    if settings_supplied
      if new_ratings_supplied
        raw_ratings = params[:ratings]

        selected_ratings =
          if raw_ratings.respond_to?(:keys)
            raw_ratings.keys
          else
            Array(raw_ratings)
          end

        @ratings_to_show =
          (selected_ratings & @all_ratings).presence || @all_ratings
      elsif form_submitted
        # An explicitly submitted form with no ratings means
        # that every checkbox was unchecked: show all ratings.
        @ratings_to_show = @all_ratings
      else
        saved_ratings = Array(session[:ratings]) & @all_ratings
        @ratings_to_show = saved_ratings.presence || @all_ratings
      end

      requested_sort = params[:sort_by]
      saved_sort = session[:sort_by]

      @sort_by =
        if Movie::SORTABLE_COLUMNS.include?(requested_sort)
          requested_sort
        elsif Movie::SORTABLE_COLUMNS.include?(saved_sort)
          saved_sort
        else
          "title"
        end

      session[:ratings] = @ratings_to_show
      session[:sort_by] = @sort_by
    else
      saved_ratings = Array(session[:ratings]) & @all_ratings
      @ratings_to_show = saved_ratings.presence || @all_ratings

      saved_sort = session[:sort_by]

      @sort_by =
        if Movie::SORTABLE_COLUMNS.include?(saved_sort)
          saved_sort
        else
          "title"
        end
    end

    @movies = Movie.with_ratings(@ratings_to_show, @sort_by)
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
