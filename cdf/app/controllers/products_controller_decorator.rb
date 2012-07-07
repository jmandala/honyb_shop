ProductsController.class_eval do
  after_filter :update_results, :only => [:index]

  def update_results
    unless params[:keywords].nil? || @products.nil?
      @products.each do |book|
        if book.google_books_update.nil?
          book.get_biblio_data!
          book.reload
        end
      end
    end
  end
end