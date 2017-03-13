class AppSettingsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :create_superuser]

  def index
    begin
      @apps_count = AwsService.describe_applications[0].size
      @endpoint = AwsService.get_db_endpoint_info
      @env = AwsService.get_env_info
      @user = current_user
    rescue Aws::RDS::Errors::DBInstanceNotFound
    rescue Aws::RDS::Errors::ServiceError
      redirect_to posts_path, notice: 'AWS Service Error'
    rescue
      Rails.application.load_tasks
      Rake::Task['db:migrate'].invoke
      redirect_to posts_path, notice: 'Database preparation: page refreshed'
    end

    @connected = ActiveRecord::Base.connection_config[:host] == @endpoint
  end

  def create_db
    begin
      AwsService.create_db
      redirect_to app_settings_path, notice: 'DB is being created...'
    rescue Aws::RDS::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Error. Check logs'
    end
  end

  def delete_db
    begin
      AwsService.delete_db
      redirect_to app_settings_path, notice: 'DB is being deleted...'
    rescue Aws::RDS::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Error. Check logs'
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

  def create_app_and_env
    begin
      AwsService.create_application_version
      AwsService.create_environment
      redirect_to app_settings_path, notice: 'Application and environment are being created...'
    rescue Aws::ElasticBeanstalk::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Error. Check logs'
    end
  end

  def terminate_env
    begin
      AwsService.terminate_environment
      redirect_to app_settings_path, notice: 'Environment is being terminated...'
    rescue Aws::ElasticBeanstalk::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Error. Check logs'
    end
  end

  def terminate_app
    begin
      AwsService.delete_application
      redirect_to app_settings_path, notice: 'Application is being deleted...'
    rescue Aws::ElasticBeanstalk::Errors::ServiceError
      redirect_to app_settings_path, notice: 'Error. Check logs'
    end
  end

  def prepare_data_migration
    SeedDump.dump(Post, file: 'db/seeds.rb')
    redirect_to app_settings_path, notice: 'Prepared data migrations'
  end

  def invoke_data_migration
    Rails.application.load_tasks
    Rake::Task['db:seed'].invoke
    redirect_to app_settings_path, notice: 'Data migrated'
  end

  def create_superuser
    User.create(email: 'admin@ucm.es', password: 'adminpass') unless User.find_by(email: 'admin@ucm.es')
    redirect_to new_user_session_path, notice: 'Account created'
  end

end
