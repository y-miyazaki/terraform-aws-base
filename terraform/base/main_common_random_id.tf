#--------------------------------------------------------------
# Generates a random ID that is created primarily to be used for unique names.
# It is used for services such as S3.
#--------------------------------------------------------------
resource "random_id" "this" {
  byte_length = 6
}
