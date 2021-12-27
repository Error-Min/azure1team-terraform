variable "resource_names" {
   default = "smlee"
}

variable "resource_group_name" {
   description = "resource group Name"
   default     = "smlee-3tier"
   # (1) 리소스 그룹 이름 변수
}

variable "location" {
   default = "korea central"
   description = "Location where resources"
   # (2) 리소스 그룹 리전 korea central -> 서울 중부
}

variable "admin_user" {
    # VM 스케일 세트의 일부가 될 VM의 관리자 계정으로 사용할 사용자 이름
   default     = "sangmin"
   # (5)
}

variable "admin_password" {
   # admin(root) 계정 암호
   default = "#Rlflqhdl21"
   # (6)
}