# Registry source: derived from the repo name — strip the "terraform-powerplatform-" prefix.
# e.g. terraform-powerplatform-res-environment → rpothin/res-environment/powerplatform
module "this" {
  source = "rpothin/ptn-environmentgroup-vnetintegration/powerplatform"

  name     = var.name
  location = var.location
}
