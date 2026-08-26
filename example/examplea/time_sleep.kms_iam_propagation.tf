resource "time_sleep" "kms_iam_propagation" {
  depends_on = [
    google_kms_crypto_key_iam_member.apigee_service_agent,
    google_kms_crypto_key_iam_member.apigee_service_agent_consumer_data,
  ]

  create_duration = "60s"
}
