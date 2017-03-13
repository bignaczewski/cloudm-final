class AwsService

  DB_INSTANCE_IDENTIFIER = 'cloudmpostgresql'
  ENV_NAME = 'cloudm-env'
  APP_NAME = 'cloudm'
  DB_USER_NAME = 'cloudmadmin'
  DB_USER_PASS = 'cloudmadminpass'
  DB_PORT = '5432'

  RDS_CLIENT = Aws::RDS::Client.new
  EB_CLIENT = Aws::ElasticBeanstalk::Client.new

  def self.create_db
    RDS_CLIENT.create_db_instance({
                                      allocated_storage: 5,
                                      db_instance_class: 'db.t2.micro',
                                      db_instance_identifier: DB_INSTANCE_IDENTIFIER,
                                      db_name: DB_INSTANCE_IDENTIFIER,
                                      engine: 'postgres',
                                      master_user_password: DB_USER_PASS,
                                      master_username: DB_USER_NAME,
                                  })
  end

  def self.get_db_endpoint_info
    resp = RDS_CLIENT.describe_db_instances({db_instance_identifier: DB_INSTANCE_IDENTIFIER})
    first = resp[:db_instances].first
    first[:endpoint][:address] if first[:db_instance_status] == 'available'
  end

  def self.delete_db
    RDS_CLIENT.delete_db_instance({db_instance_identifier: DB_INSTANCE_IDENTIFIER, skip_final_snapshot: true})
  end

  def self.create_application_version
    latest_commit_id = get_latest_commid_id
    EB_CLIENT.create_application_version({
                                             application_name: APP_NAME, # required
                                             version_label: latest_commit_id, # required
                                             description: 'UCM final project app',
                                             source_build_information: {
                                                 source_type: 'Git', # required, accepts Git, Zip
                                                 source_repository: 'CodeCommit', # required, accepts CodeCommit, S3
                                                 source_location: 'cloudm/' + latest_commit_id, # required
                                             },
                                             auto_create_application: true,
                                             process: true
                                         })
  end

  def self.delete_application
    EB_CLIENT.delete_application({application_name: APP_NAME})
  end

  def self.create_environment(env_name = ENV_NAME, db_hostname = get_db_endpoint_info, db_name = DB_INSTANCE_IDENTIFIER,
      db_username = DB_USER_NAME, db_pass = DB_USER_PASS, db_port = DB_PORT)
    EB_CLIENT.create_environment({
                                     application_name: APP_NAME,
                                     environment_name: env_name,
                                     version_label: get_latest_commid_id,
                                     solution_stack_name: '64bit Amazon Linux 2016.09 v2.3.2 running Ruby 2.3 (Puma)',
                                     option_settings: [
                                         {
                                             namespace: 'aws:elasticbeanstalk:application:environment',
                                             option_name: 'SECRET_KEY_BASE',
                                             value: SecureRandom.hex(64)
                                         },
                                         {
                                             namespace: 'aws:autoscaling:launchconfiguration',
                                             option_name: 'InstanceType',
                                             value: 't2.micro'
                                         }
                                     ] + generate_db_opts(db_hostname, db_name, db_username, db_pass, db_port)
                                 })
  end

  def self.get_env_info
    resp = EB_CLIENT.describe_environments
    info = resp[:environments].first
    return info[:status], info[:health], info[:endpoint_url] if resp[:environments].first
  end

  # basically it only updates the db connection settings
  def self.update_environment(env_name = ENV_NAME, db_hostname = get_db_endpoint_info, db_name = DB_INSTANCE_IDENTIFIER,
      db_username = DB_USER_NAME, db_user_pass = DB_USER_PASS, db_port = DB_PORT)
    EB_CLIENT.update_environment({
                                     environment_name: env_name,
                                     version_label: Random.rand.to_s,
                                     option_settings: generate_db_opts(db_hostname, db_name, db_username, db_user_pass, db_port)
                                 })
  end

  def self.terminate_environment(env_name = ENV_NAME)
    EB_CLIENT.terminate_environment({environment_name: env_name})
  end

  def self.generate_db_opts(db_hostname = get_db_endpoint_info, db_name = DB_INSTANCE_IDENTIFIER, db_username = DB_USER_NAME,
      db_user_pass = DB_USER_PASS, db_port = DB_PORT)
    [{
         namespace: 'aws:elasticbeanstalk:application:environment',
         option_name: 'RDS_DB_NAME',
         value: db_name
     },
     {
         namespace: 'aws:elasticbeanstalk:application:environment',
         option_name: 'RDS_USERNAME',
         value: db_username
     },
     {
         namespace: 'aws:elasticbeanstalk:application:environment',
         option_name: 'RDS_PASSWORD',
         value: db_user_pass
     },
     {
         namespace: 'aws:elasticbeanstalk:application:environment',
         option_name: 'RDS_HOSTNAME',
         value: db_hostname
     },
     {
         namespace: 'aws:elasticbeanstalk:application:environment',
         option_name: 'RDS_PORT',
         value: db_port
     }]
  end

  def self.get_latest_commid_id
    codecommit = Aws::CodeCommit::Client.new
    resp = codecommit.get_branch({repository_name: 'cloudm', branch_name: 'master'})
    resp[:branch][:commit_id]
  end

  def self.describe_applications
    EB_CLIENT.describe_applications
  end

end