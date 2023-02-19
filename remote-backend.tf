# #important>>>>>>first-step-run-1th-alone>>>>>>>>>>>next-step-run-2th----------------
# #1th----------------------bucket-to-save-state-file----------------------
# resource "aws_s3_bucket" "s3-bucket-data" {
#   bucket = "terraform-up-and-running-data"
#   #------------------can't-delete-s3_bucket------------------------------
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# #1th--------------------enable-version-for-state-file--------------------
# resource "aws_s3_bucket_versioning" "enabled" {
#     bucket = aws_s3_bucket.s3-bucket-data.bucket
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# #1th----------------------no_sql-dataBase-----------------------
# resource "aws_dynamodb_table" "locks" {
#     name = "terraform-up-and-running-locks"
#     billing_mode = "PAY_PER_REQUEST"
#     hash_key = "LockID"
#     #----------colume-for-table-------------------------
#     attribute {
#       name = "LockID"
#       type = "S"
#     }
  
# }

#2th------------------------------backend----------------------
terraform {
  backend "s3" {
    #--------------data-for-bucket--------------------------
    bucket = "terraform-up-and-running-data"
    #---------path-in-s3----------------
    key = "project/terraform.tfstate"
    region = "us-east-2"
    #--------------data-for-dynamodb-table------------------
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}