creds = JSON.load(File.read('config/secrets.json'))
Aws.config.update(
    # credentials: Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key']),
    access_key_id: creds['access_key_id'],
    secret_access_key: creds['secret_access_key'],
    region: 'eu-west-1',
)