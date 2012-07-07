class GoogleBook

  def initialize(isbn13)
    @book_info = ActiveSupport::JSON.decode(open "https://www.googleapis.com/books/v1/volumes?q=#{isbn13}")
  end

  def title
    @book_info["items"].first["volumeInfo"]["title"]
  end

  def description
    @book_info["items"].first["volumeInfo"]["description"]
  end

  def subtitle
    @book_info["items"].first["volumeInfo"]["subtitle"]
  end

  def authors
    @book_info["items"].first["volumeInfo"]["authors"]
  end

  def publisher
    @book_info["items"].first["volumeInfo"]["publisher"]
  end

  def published_date
    @book_info["items"].first["volumeInfo"]["publishedDate"]
  end

  def page_count
    @book_info["items"].first["volumeInfo"]["pageCount"]
  end

  def thumbnail_url
    @book_info["items"].first["volumeInfo"]["imageLinks"]["thumbnail"]
  end

  def matching_count
    @book_info["totalItems"] || 0
  end
end