require 'rails-settings-ui'

#= Application-specific
#
# # You can specify a controller for RailsSettingsUi::ApplicationController to inherit from:
# RailsSettingsUi.parent_controller = 'SettingsController' # default: '::ApplicationController'
#
# # Render RailsSettingsUi inside a custom layout (set to 'application' to use app layout, default is RailsSettingsUi's own layout)
# RailsSettingsUi::ApplicationController.layout 'admin'

Rails.application.config.to_prepare do
  RailsSettingsUi::ApplicationController.module_eval { layout 'application' }
  RailsSettingsUi.inline_main_app_routes!
  RailsSettingsUi::ApplicationController.module_eval { before_action :authenticate_user! }
end
