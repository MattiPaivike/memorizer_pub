# Consumer service

This service runs as an AWS lambda function. It reads the AWS sqs queue, passes messages to OpenAI and writes processed messages to the database.

## SSM parameter store schema:

Requires the following AWS SSM parameter store names as environment variables:

```
DB_HOST_SSM_NAME
DB_PASS_SSM_NAME
DB_USER_SSM_NAME
DB_NAME_SSM_NAME
OPENAI_API_KEY_SSM_NAME
OPENAI_API_VERSION_SSM_NAME # optional, needed if OPENAI_API_TYPE="azure". Example value: 2023-07-01-preview.
AZURE_OPENAI_API_BASE_URL_SSM_NAME # only needed if OPENAI_API_TYPE="azure". Example value: https://open-ai-deployment.openai.azure.com/
OPENAI_COMPLETION_MODEL_DEPLOYMENT_NAME_SSM_NAME # name of the openai model for completion(note main text). Example: "gpt-3.5-turbo". NOTE! If you are using Azure OpenAI this is the name of the Azure OpenAI model deployment. Can be found in Azure: Azure AI Studio > Deployments under Deployment Name.
```

Also other environment variables needed:

```
DEBUG = # set to "1" if you want debug message, otherwise not needed
OPENAI_API_TYPE= # set to "azure" if using Azure OpenAI, defaults to "openai"
LOCAL_EXECUTION = # set to "1" if running locally (not in AWS), otherwise not needed, used for local testing
```
