variable "region" {
  default = "us-east-2"
}

variable "python_default_version" {
  default = "python3.8"
}

variable "lambda_get_from_api_name" {
  default = "get_data_from_external_api"
}

variable "lambda_get_from_api_path" {
  default = "src/lambdaGetFromAPI/getDataFromPunk.zip"
}

variable "lambda_get_from_api_handler" {
  default = "getDataFromPunk.lambda_handler"
}

variable "lambda_get_from_api_description" {
  default = "get data from an external API"
}

variable "lambda_data_cleaned_transformation_name" {
  default = "data_cleaned_transformation"
}

variable "lambda_data_cleaned_transformation_path" {
  default = "src/lambdaCleanedTransformation/dataTransformation.zip"
}

variable "lambda_data_cleaned_transformation_handler" {
  default = "dataTransformation.lambda_handler"
}

variable "lambda_data_cleaned_transformation_description" {
  default = "filter the raw data for (name, abv, ibu, target_fg, target_og, ebc, srm and ph)to store on a bucket S3 in CSV format."
}

