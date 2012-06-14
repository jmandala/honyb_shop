ActionController::Base.class_eval do

  def default_url_options(options={})
    if params[:embed]
      options.merge!(:embed => 'embed')
    else
      options
    end
  end
end