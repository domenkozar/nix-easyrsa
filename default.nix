{}:

with import <nixpkgs> {};
with pkgs;

let
  fields = {
    country = "SI";
    province = "SI";
    city = "Ljubljana";
    organization = "My Organization";
    email = "info@mycompany.com";
    cname = "mycompany";
  };
in stdenv.mkDerivation rec {
  name = "openvpn-keys";

  src = ./.;

  buildInputs = [ easyrsa ];

  installPhase = ''
    mkdir -p $out
    touch $out/foo

    # This variable should point to
    # the requested executables
    #
    export PKCS11TOOL="pkcs11-tool"

    # This variable should point to
    # the openssl.cnf file included
    # with easy-rsa.
    export EASY_RSA="${easyrsa}/share/easy-rsa"

    # Edit this variable to point to
    # your soon-to-be-created key
    # directory.
    export KEY_DIR="$out"

    # Increase this to 2048 if you
    # are paranoid.  This will slow
    # down TLS negotiation performance
    # as well as the one-time DH parms
    # generation process.
    export KEY_SIZE=2048

    # In how many days should the root CA key expire?
    export CA_EXPIRE=3650

    # In how many days should certificates expire?
    export KEY_EXPIRE=3650

    # certificate fields
    export KEY_COUNTRY="${fields.country}"
    export KEY_PROVINCE="${fields.province}"
    export KEY_CITY="${fields.city}"
    export KEY_ORG="${fields.organization}"
    export KEY_EMAIL="${fields.email}"
    export KEY_CNAME="${fields.cname}"

    # needed for openssl random file
    export HOME=$out

    export SSLCNF=$($EASY_RSA/whichopensslcnf $EASY_RSA)
    cp $SSLCNF openssl.cnf
    chmod 744 openssl.cnf
    echo "commonName_default        = $ENV::KEY_CNAME" >> openssl.cnf
    export KEY_CONFIG=`pwd`/openssl.cnf

    ${easyrsa}/bin/clean-all
    echo "Generating CA"
    ${easyrsa}/bin/build-ca --batch
    echo "Generating DH key"
    ${easyrsa}/bin/build-dh --batch
    echo "Generating server key"
    ${easyrsa}/bin/build-key-server --batch server
    echo "Generating client key"
    ${easyrsa}/bin/build-key --batch client
  '';
}
