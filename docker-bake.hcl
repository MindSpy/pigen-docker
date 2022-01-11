variable "PKG_PROXY"  {  }
variable "GIT_BRANCH" {  }
variable "BUILD_DATE" {  }
variable "PIGEN_REPO" { default = "https://github.com/RPi-Distro/pi-gen" }
variable "PIGEN_VER"  { default = "master" }

group "default" {
  targets = [ 
    "pigen", "latest", "date"
    ]
}

target "latest" {
  inherits = ["pigen"]
  tags = [ "mindspy/pigen:latest" ]
}

target "date" {
  inherits = ["pigen"]
  tags = [ "mindspy/pigen:${BUILD_DATE}" ]
}

target "dev" {
  tags = [ "mindspy/pigen:dev" ]
  inherits = ["pigen"]
}

target "pigen" {
  platforms = [ 
    "linux/arm64", "linux/arm/v6", "linux/arm/v7"
    ]
  context = "."
  tags = [ "mindspy/pigen:${PIGEN_VER}" ]
  args = {
      PKG_PROXY = "${PKG_PROXY}"
      PIGEN_REPO = "${PIGEN_REPO}"
      PIGEN_VER = "${PIGEN_VER}"
    }
}