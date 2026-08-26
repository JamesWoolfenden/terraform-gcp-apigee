locals {
  # The KMS key ring, the Apigee analytics region and every runtime instance
  # location must agree — an instance's disk key has to live in that instance's
  # own region — so they are derived from one place rather than repeated.
  region = "europe-west2"
}
