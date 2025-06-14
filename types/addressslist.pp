@summary Validate a list of IPV4 or IPV6 addresses
type Network::AddressList = Variant[Stdlib::IP::Address::V4::Nosubnet, Array[Stdlib::IP::Address::V4::Nosubnet]]
type Network::AddressList::CIDR = Variant[Stdlib::IP::Address::V4::CIDR, Array[Stdlib::IP::Address::V4::CIDR]]
