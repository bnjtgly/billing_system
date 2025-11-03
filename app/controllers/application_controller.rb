class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :admin_user?

  private
    def admin_user?
      role_name = Current.user&.role&.name.to_s
      role_name.casecmp('admin').zero?
    end

    def require_admin!
      return if admin_user?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
end
