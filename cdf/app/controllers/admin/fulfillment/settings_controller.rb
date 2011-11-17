class Admin::Fulfillment::SettingsController < Admin::BaseController

  def update
    Cdf::Config.set(params[:preferences]) if Cdf::Config.instance

    respond_to do |format|
      format.html {
        redirect_to admin_fulfillment_settings_path
      }
    end
  end

end
