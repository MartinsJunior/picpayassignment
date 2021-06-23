resource "aws_kinesis_stream" "stream_data_from_lambda" {
  name             = "stream_data_from_lambda"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}