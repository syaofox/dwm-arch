# agenix secrets
# See https://github.com/ryantm/agenix for usage
# Place .age files here and define secrets:
# let
#   userKeys = [ "ssh-ed25519 AAAAC3..." ];
#   systemKeys = [ "ssh-ed25519 AAAAC3..." ];
# in
# {
#   "ssh-key.age".publicKeys = userKeys ++ systemKeys;
#   "gpg-key.age".publicKeys = userKeys ++ systemKeys;
# }
{
}
