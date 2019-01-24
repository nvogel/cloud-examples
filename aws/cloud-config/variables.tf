variable "tags" {
  description = "Required tags lists"
  type = "list"
  default = [
     {
     tag1Key = "Name"
     tag2Key = "Project"
     },
     {
     tag1Key = "Support"
     tag1Value = "support@here.tld"
     }
  ]
}
