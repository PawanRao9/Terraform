variable "aws_instance_type" {
  description = "what type of instance you wan to create ?"
  type = string

  validation {
    condition = var.aws_instance_type=="t2.micro" || var.aws_instance_type=="t2.micro"
    error_message = "only t2 and t3-micro are allowed"
  }
}


# variable "root_volume_size" {
#   type = number
#   default = 20        # if you are not providing anything externally then it will take from the default 
# }

# variable "root_volume_type" {
#     type = string
#     default = "gp2"
  
# }


variable "ec2_config" {
    type = object({
      v_type = string
      v_size = string 
    })
    default = {
      v_size = "gp2"
      v_type = "20"
    }
  
}

variable "additional_tags" {
    type = map(string)         # expecting key=value format
    default = {}
  
}