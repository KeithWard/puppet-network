# @summary Validate lists of IPV4 or IPV6 addresses
type Network::AddressList::V4 = Variant[Stdlib::IP::Address::V4::Nosubnet, Array[Stdlib::IP::Address::V4::Nosubnet]]
type Network::AddressList::V4::CIDR = Variant[Stdlib::IP::Address::V4::CIDR, Array[Stdlib::IP::Address::V4::CIDR]]
type Network::AddressList::V6 = Variant[Stdlib::IP::Address::V6::Nosubnet, Array[Stdlib::IP::Address::V6::Nosubnet]]
type Network::AddressList::V6::CIDR = Variant[Stdlib::IP::Address::V6::CIDR, Array[Stdlib::IP::Address::V6::CIDR]]
