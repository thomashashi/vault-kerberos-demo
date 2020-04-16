# Vault Kerberos Authentication Demo

## Background

This repository contains a [Vagrant](https://vagrant.io) setup to demonstrate
the [Vault Kerberos Authentication Method](https://www.vaultproject.io/docs/auth/kerberos)
introduced in Vault 1.4. 

It contains three VMs:

1. A Kerberos Key Distribution Center (KDC)
1. An OpenLDAP server (LDAP is required for directory information by the auth plugin)
1. A Vault server

On startup, everything is running, and your Vault server is initialized and unsealed.
There's a `vagrant` user with appropriate credentials and LDAP directory entry already.

## Running the demo

1. `vagrant up` - this takes about five minutes on my laptop
1. `vagrant ssh vault` - you run the demo here
1. `./run-demo` - prints out and then runs the commands necessary to:
   1. Mount the auth method
   1. View the Vault server's keytab (pre-provisioned)
   1. Encode it
   1. Configure the Kerberos authentication method
   1. Configure the LDAP settings in the Kerberos authentication method
   1. Map the LDAP group `dev` to the `dev` policy in Vault
   1. View the `vagrant` user's credentials
   1. Authenticate

## Bonus demo

The `vault login` command only supports authenticating via a _keytab_, which is
usual for services and machines, but is a bit unusual for users, who would typically
authenticate to Kerberos using a passphrase and then have cached credentials.
The method above simply gives the `vagrant` user a keytab to make the demo work.

This is, at first glance, a limitation of the Golang Kerberos libraries - how one
accesses the credentials cache is highly dependent on your implemenation of
Kerberos (MIT, Heimdal, Active Directory), and the format is not standardized. 
Most programming languages for which there are Kerberos libraries handle this by
simply linking against the Kerberos distribution's libraries, but the Golang
one is pure Go. 

However, the Vault Kerberos authentication mechanism is simply passing a 
`Authorization: Negotiate` header obtained by SPNEGO, so if you've got the pile
of Kerberos/GSSAPI/SPNEGO goo in your programming language, and it can access the
user's credentials cache, you can authenticate as a typical Kerberos user would
expect. This demo contains examplar Python code to do so from the 
[Vault Kerberos Authentication Plugin](https://github.com/hashicorp/vault-plugin-auth-kerberos)
repository.

### Running the bonus demo

1. Make sure you're still connected to the `vault` VM
1. See that the `vagrant` user has no cached credentials
1. Authenticate as the `vagrant` user with the (pre-provisioned) user keytab
1. View the now cached credentials
1. Look at the Python code
1. Run the code and use `jq` to pretty-print the returned Vault output
1. The returned json is stashed in `cat /home/vagrant/.ccache-auth.out` so you can
   look at it later

## Environment

When you `vagrant up`, several things are provisioned for you. All of the stashed
credentials mentioned below are in the `vagrant` user's home directory on the 
`vault` VM.

1. A KDC for the realm `EXAMPLE.LOCAL` - MIT Kerberos in this example
1. A Kerberos administrative user `admin/admin@EXAMPLE.LOCAL` with the password
   stashed in `.admin.admin.pwd`
1. A `vagrant` user in Kerberos, with `vagrant.keytab` as their keytab
1. A `vault/vault.example.local` user in Kerberos, with `vault/keytab` as its keytab
1. An OpenLDAP server with a DN of `dc=example,dc=local`
1. A `vagrant` and a `vault` user in LDAP, with corresponding LDAP passwords in 
   `vagrant.ldap.password` and `vault.ldap.password` (this demo uses simple bind
   and does not do SASL)
1. An unsealed Vault with the unseal key in `.vault.unseal_key` and the Vault root
   user token in `.vault.root_token`
1. The environment variables `VAULT_ADDR`, `VAULT_UNSEAL_KEY` set with what you'd
   expect them to be. `VAULT_ROOT_TOKEN` is set to the Vault root token; when you
   first login `VAULT_TOKEN` is set to the same value, but this allows you to easily
   switch back and forth between Vault tokens

### Useful commands
1. `ldapsearch -x -b ou=Users,dc=example,dc=local uid=vagrant` - Examine the `vagrant`
   user LDAP entry
1. `ldapsearch -x -b ou=Groups,dc=example,dc=local cn=devs` - Examine the `devs` group
   LDAP entry
1. `kadmin -p admin/admin -w $(cat ~/.admin.admin.pwd)` - Connect to the Kerberos 
   administrative server
   1. `getprinc vagrant` - examine the `vagrant` user's entry in the KDC
   1. `getprinc vault/vault.example.local` - do the same for the `vault` user

## References
1. [Vault Kerberos Auth Plugin Documentation](https://www.vaultproject.io/docs/auth/kerberos)
1. [The Wikipedia entry for Kerberos](https://en.wikipedia.org/wiki/Kerberos_(protocol))
1. [RFC 4120: The Kerberos Network Authentication Service(v5)](https://tools.ietf.org/html/rfc4120)
1. [Designing an Authentication System: a Dialogue in Four Scenes](https://web.mit.edu/kerberos/dialogue.html) -
   still one of the best ways of understanding the design of Kerberos
