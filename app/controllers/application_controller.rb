class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all

  def default_url_options(options={})
    logger.debug "Embed: #{params[:embed]}"
    { :embed => 'embed'} if params[:embed]
  end
end
