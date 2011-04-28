class WelcomeController < ApplicationController
  MOBILIZED = [:index]
  before_filter :unmobilized, :except => MOBILIZED
  before_filter :mobilized, :only => MOBILIZED
  
  caches_action :index, :expires_in => 15.minute, :if => Proc.new {|c|
    !c.send(:logged_in?) && c.send(:flash).blank? && !c.request.format.mobile?
  }
  
  def index
    respond_to do |format|
      format.html do
        @observations = Observation.all( 
          :include => :photos,
          :limit => 4,
          :order => "observations.created_at DESC",
          :conditions => "latitude IS NOT NULL AND longitude IS NOT NULL " + 
                         "AND photos.id > 0")
      end
      format.mobile
    end
  end
  
  def toggle_mobile
    session[:mobile_view] = session[:mobile_view] ? false : true
    redirect_to params[:return_to] || session[:return_to] || "/"
  end
end
