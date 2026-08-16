terraform {}

# number list

variable "num_list" {
  type    = list(number)
  default = [1, 2, 3, 4, 5]
}


# object list of persons
variable "person_list" {
  type = list(object({
    fname = string
    lname = string
  }))
  default = [{
    fname = "raju"
    lname = "rastogi"
    }, {
    fname = "sham"
    lname = "paul"
    }, {
    fname = "mohit"
    lname = "cauhan"
  }]
}

variable "map_list" {
  type = map(number)
  default = {
    "one"   = 1
    "two"   = 2
    "three" = 3
  }

}


# calculations

locals {
  mul = 2 * 2
  add = 2 + 2
  eq  = 2 != 3

  #double the list
  double =[ for num in var.var.num_list : num * 2] 

  #odd number
  odd = [for num in var.var.num_list : num if num%2 != 0]

  #to get the fname from the list
  fname_list = [for person in var.var.person_list: person.fname]
}

output "output" {
  value = local.double
}
output "output" {
   value = local.odd
}
