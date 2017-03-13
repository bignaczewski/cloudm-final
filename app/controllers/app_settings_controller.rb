class AppSettingsController < ApplicationController

  before_action :authenticate_user!

  def index
    begin
      @endpoint = AwsService.get_db_endpoint_info
    rescue Aws::RDS::Errors::ServiceError
      redirect_to posts_path, notice: 'Could not connect to Amazon AWS'
    end
    @connected = ActiveRecord::Base.connection_config[:host] == @endpoint
  end

  def create_db
    begin
      AwsService.create_db
      redirect_to app_settings_path, notice: 'DB is being created...'
    rescue Aws::RDS::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Could not connect to Amazon AWS'
    end
  end

  def delete_db
    begin
      AwsService.delete_db
      redirect_to app_settings_path, notice: 'DB is being deleted...'
    rescue Aws::RDS::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Could not connect to Amazon AWS'
    end
  end

  def connect_db
    ActiveRecord::Base.establish_connection({encoding: 'unicode', port: AwsService::DB_PORT,
                                             adapter: 'postgresql', database: AwsService::DB_INSTANCE_IDENTIFIER,
                                             host: AwsService.get_db_endpoint_info,
                                             username: AwsService::DB_USER_NAME, password: AwsService::DB_USER_PASS}).connection
    redirect_to app_settings_path, notice: 'Connecting to the Amazon RDS...'
  end

  def connect_db_local
    ActiveRecord::Base.establish_connection({database: 'cloudm_development', adapter: 'postgresql'}).connection
    redirect_to app_settings_path, notice: 'Connecting to the local db...'
  end

end
