ProductsController.class_eval do
  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products

    unless params[:keywords].nil? || @products.nil?
      @products.each do |book|
        if book.google_books_update.nil?
          book.get_biblio_data!
          book.reload
        end
      end
    end

    respond_with(@products)
  end
end