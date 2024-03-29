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
  tags = [ 
    "mindspy/pigen:latest",
    "mindspy/pigen:latest-stage",
    "mindspy/pigen:latest-export"
  ]
}

target "date" {
  inherits = ["pigen"]
  tags = [ "mindspy/pigen:${BUILD_DATE}" ]
}

target "dev" {
  tags = [ "mindspy/pigen:dev" ]
  inherits = ["pigen"]
}

target "raspios" {
  inherits = [ "pigen" ]
  platforms = [ 
    "linux/arm64/v8", "linux/arm/v7"
    ]
  dockerfile = "raspios.Dockerfile"
  tags = [ 
    "mindspy/raspios:latest", 
    "mindspy/raspios:bullseye" 
    ]
}

target "pigen" {
  platforms = [ 
    "linux/amd64", "linux/386",
    "linux/arm64/v8", "linux/arm/v7"
    ]
  context = "."
  tags = [ "mindspy/pigen:${PIGEN_VER}" ]
  args = {
      RELEASE = "bullseye"
      PKG_PROXY = "${PKG_PROXY}"
      PIGEN_REPO = "${PIGEN_REPO}"
      PIGEN_VER = "${PIGEN_VER}"
    }
}
