Module AwsSecrets
  # Use this code snippet in your app.
  # If you need more information about configurations or implementing the sample code, visit the AWS docs:
  # https://aws.amazon.com/developer/language/ruby/

  require 'aws-sdk-secretsmanager'

  def get_secret
    client = Aws::SecretsManager::Client.new(region: 'us-east-1')

    begin
      get_secret_value_response = client.get_secret_value(secret_id: 'rds!db-6f8b3e02-fe92-4505-9641-d5ce52de5d3b')
    rescue StandardError => e
      # For a list of exceptions thrown, see
      # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
      raise e
    end

    secret = get_secret_value_response.secret_string
    # Your code goes here.
  end
end