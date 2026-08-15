{ username, ... }:
{
  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJYACvhqmm3+7Bq+Po0dK+PQcfX0ZFyusN2669SgQUg iavcoelho@protonmail.com"
  ];
}
