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
    begin
      return Date.parse @book_info["items"].first["volumeInfo"]["publishedDate"]
    rescue => e
      if /\d{4}-\d{2}/ =~ @book_info["items"].first["volumeInfo"]["publishedDate"]        # we want to create a valid date, but Google sometimes just gives us year and month, no day.
        begin
          Date.parse "#{@book_info['items'].first['volumeInfo']['publishedDate']}-01"     # and if they didn't even give us that, give up on it altogether!
        rescue
          nil
        end
      end
    end
  end

  def page_count
    @book_info["items"].first["volumeInfo"]["pageCount"]
  end

  def thumbnail_url
    thumbnail = @book_info["items"].first["volumeInfo"]["imageLinks"]["thumbnail"] unless @book_info["items"].first["volumeInfo"]["imageLinks"].nil?
    if thumbnail.nil?
      thumbnail
    else
      thumbnail = thumbnail.gsub "&edge=curl", ""         # take out the edge=curl parameter from the middle of the string
      thumbnail = thumbnail.gsub "?edge=curl&", "?"       # take it out if it's the first thing in the string too. This won't work if it's the first AND only parameter, but that should never occur
    end
  end

  def raw
    @book_info["items"].first
  end

  def matching_count
    @book_info["totalItems"] || 0
  end
end