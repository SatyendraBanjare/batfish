parser grammar CiscoParser;

import
Cisco_common, Cisco_acl, Cisco_bgp, Cisco_eigrp, Cisco_ignored, Cisco_interface, Cisco_isis, Cisco_mpls, Cisco_ospf, Cisco_rip, Cisco_routemap, Cisco_static;

options {
   superClass = 'org.batfish.grammar.BatfishParser';
   tokenVocab = CiscoLexer;
}

@header {
package org.batfish.grammar.cisco;
}

@members {
   private boolean _nonNexus;
   
   public void setNonNexus(boolean b) {
      _nonNexus = b;
   }
}

address_aiimgp_stanza
:
   ADDRESS ~NEWLINE* NEWLINE
;

address_family_multicast_stanza
:
   ADDRESS_FAMILY
   (
      IPV4
      | IPV6
   ) NEWLINE address_family_multicast_tail
;

address_family_multicast_tail
:
   (
      MULTIPATH NEWLINE
      | interface_multicast_stanza
   )*
;

address_family_vrfd_stanza
:
   ADDRESS_FAMILY
   (
      IPV4
      | IPV6
   )
   (
      MULTICAST
      | UNICAST
   )? NEWLINE afvrfd_stanza*
   (
      EXIT_ADDRESS_FAMILY NEWLINE
   )?
;

afvrfd_stanza
:
   null_afvrfd_stanza
;

aiimgp_stanza
:
   address_aiimgp_stanza
;

allow_iimgp_stanza
:
   ALLOW ~NEWLINE* NEWLINE aiimgp_stanza*
;

asa_comment_stanza
:
   COLON ~NEWLINE* NEWLINE
;

banner_stanza
:
   BANNER
   (
      (
         (
            ESCAPE_C ~ESCAPE_C* ESCAPE_C
         )
         |
         (
            POUND ~POUND* POUND
         )
         |
         (
            NEWLINE ~EOF_LITERAL* EOF_LITERAL
         )
      )
   ) NEWLINE?
;

certificate_stanza
:
   CERTIFICATE ~QUIT* QUIT NEWLINE
;

cisco_configuration
:
   NEWLINE?
   (
      sl += stanza
   )+ COLON? NEWLINE? EOF
;

cm_end_class_map
:
   END_CLASS_MAP NEWLINE
;

cm_match
:
   MATCH cm_match_tail
;

cm_match_tail
:
   cmm_access_group
   | cmm_cos
   | cmm_default_inspection_traffic
   | cmm_dscp
   | cmm_mpls
   | cmm_non_client_nrt
   | cmm_port
   | cmm_qos_group
;

cmm_access_group
:
   ACCESS_GROUP
   (
      num = DEC
      |
      (
         NAME name = variable
      )
   ) NEWLINE
;

cmm_cos
:
   COS DEC NEWLINE
;

cmm_default_inspection_traffic
:
   DEFAULT_INSPECTION_TRAFFIC NEWLINE
;

cmm_dscp
:
   IP? DSCP
   (
      dscp_types += dscp_type
   )+ NEWLINE
;

cmm_mpls
:
   MPLS ~NEWLINE* NEWLINE
;

cmm_non_client_nrt
:
   NON_CLIENT_NRT NEWLINE
;

cmm_port
:
   PORT
   (
      TCP
      | UDP
   ) port_specifier NEWLINE
;

cmm_qos_group
:
   QOS_GROUP DEC NEWLINE
;

cp_ip_access_group
:
   IP ACCESS_GROUP name = variable
   (
      VRF vrf = variable
   )?
   (
      IN
      | OUT
   ) NEWLINE
;

cp_ip_flow
:
   IP FLOW MONITOR name = variable
   (
      INPUT
      | OUTPUT
   ) NEWLINE
;

cp_management_plane
:
   MANAGEMENT_PLANE NEWLINE mgp_stanza*
;

cp_null
:
   NO?
   (
      EXIT
   ) ~NEWLINE* NEWLINE
;

cp_service_policy
:
   SERVICE_POLICY
   (
      INPUT
      | OUTPUT
   ) name = variable NEWLINE
;

del_stanza
:
   DEL ~NEWLINE* NEWLINE
;

hostname_stanza
:
   (
      HOSTNAME
      | SWITCHNAME
   ) name = ~NEWLINE* NEWLINE
;

iimgp_stanza
:
   allow_iimgp_stanza
;

imgp_stanza
:
   interface_imgp_stanza
   | null_imgp_stanza
;

inband_mgp_stanza
:
   (
      INBAND
      | OUT_OF_BAND
   ) NEWLINE imgp_stanza*
;

interface_imgp_stanza
:
   INTERFACE ~NEWLINE* NEWLINE iimgp_stanza*
;

interface_multicast_stanza
:
   INTERFACE ~NEWLINE* NEWLINE
   (
      BSR_BORDER NEWLINE
   )?
   (
      ENABLE NEWLINE
   )?
;

ip_as_path_regex_mode_stanza
:
   IP AS_PATH REGEX_MODE
   (
      ASN
      | STRING
   ) NEWLINE
;

ip_default_gateway_stanza
:
   IP DEFAULT_GATEWAY gateway = IP_ADDRESS NEWLINE
;

ip_pim
:
   PIM
   (
      VRF vrf = variable
   )? ip_pim_tail
;

ip_pim_tail
:
   pim_accept_register
   | pim_accept_rp
   | pim_null
   | pim_rp_address
   | pim_rp_announce_filter
   | pim_rp_candidate
   | pim_send_rp_announce
   | pim_spt_threshold
   | pim_ssm
;

ip_route_stanza
:
   IP ROUTE
   (
      VRF vrf = ~NEWLINE
   )? ip_route_tail
;

ip_route_tail
:
   (
      (
         address = IP_ADDRESS mask = IP_ADDRESS
      )
      | prefix = IP_PREFIX
   )
   (
      nexthopip = IP_ADDRESS
      | nexthopint = interface_name
      | nexthopprefix = IP_PREFIX
      | distance = DEC
      |
      (
         TAG tag = DEC
      )
      | perm = PERMANENT
      |
      (
         TRACK track = DEC
      )
      |
      (
         NAME variable
      )
   )* NEWLINE
;

ip_route_vrfc_stanza
:
   IP ROUTE ip_route_tail
;

l_access_class
:
   ACCESS_CLASS
   (
      (
         (
            EGRESS
            | INGRESS
         ) name = variable
      )
      |
      (
         name = variable
         (
            IN
            | OUT
         )
      )
   ) VRF_ALSO? NEWLINE
;

l2vpn_stanza
:
   L2VPN NEWLINE xconnect_stanza*
;

mgmt_ip_access_group
:
   IP ACCESS_GROUP name = variable
   (
      IN
      | OUT
   ) NEWLINE
;

mgmt_null
:
   NO?
   (
      AUTHENTICATION
      | EXIT
      | IDLE_TIMEOUT
      | SHUTDOWN
   ) ~NEWLINE* NEWLINE
;

mgp_stanza
:
   inband_mgp_stanza
;

multicast_routing_stanza
:
   MULTICAST_ROUTING NEWLINE
   (
      address_family_multicast_stanza
   )*
;

no_ip_access_list_stanza
:
   NO IP ACCESS_LIST ~NEWLINE* NEWLINE
;

ntp_access_group
:
   ACCESS_GROUP
   (
      IPV4
      | IPV6
      |
      (
         PEER
         (
            name = variable
         )
      )
      |
      (
         QUERY_ONLY
         (
            name = variable
         )
      )
      |
      (
         SERVE
         (
            name = variable
         )
      )
      |
      (
         SERVE_ONLY
         (
            name = variable
         )
      )
      |
      (
         VRF vrf = variable
      )
   )+ NEWLINE
;

ntp_common
:
   ntp_access_group
   | ntp_peer
   | ntp_server
   | ntp_source
   | ntp_update_calendar
;

ntp_peer
:
   PEER ~NEWLINE* NEWLINE
;

ntp_server
:
   SERVER ~NEWLINE* NEWLINE
;

ntp_source
:
   SOURCE ~NEWLINE* NEWLINE
;

ntp_update_calendar
:
   UPDATE_CALENDAR ~NEWLINE* NEWLINE
;

null_stanza
:
   asa_comment_stanza
   | banner_stanza
   | certificate_stanza
   | del_stanza
   | no_ip_access_list_stanza
   | null_block_stanza
   | null_standalone_stanza_DEPRECATED_DO_NOT_ADD_ITEMS
   | srlg_stanza
;

null_afvrfd_stanza
:
   MAXIMUM ~NEWLINE* NEWLINE
;

null_imgp_stanza
:
   NO?
   (
      VRF
   ) ~NEWLINE* NEWLINE
;

null_vrfd_stanza
:
   (
      RD
      | ROUTE_TARGET
   ) ~NEWLINE* NEWLINE
;

o_network
:
   NETWORK name = variable NEWLINE o_network_tail*
;

o_network_tail
:
   on_description
   | on_fqdn
   | on_host
   | on_nat
   | on_range
   | on_subnet
;

o_service
:
   SERVICE name = variable NEWLINE o_service_tail*
;

o_service_tail
:
   os_description
   | os_service
;

og_icmp_type
:
   ICMP_TYPE name = variable NEWLINE og_icmp_type_tail*
;

og_icmp_type_tail
:
   ogit_group_object
   | ogit_icmp_object
;

og_ip_address
:
   IP ADDRESS name = variable NEWLINE og_ip_address_tail*
;

og_ip_address_tail
:
   ogipa_host_info
   | ogipa_ip_addresses
;

og_network
:
   NETWORK name = variable NEWLINE og_network_tail*
;

og_network_tail
:
   ogn_group_object
   | ogn_network_object
;

og_protocol
:
   PROTOCOL name = variable NEWLINE og_protocol_tail*
;

og_protocol_tail
:
   ogp_description
   | ogp_group_object
   | ogp_protocol_object
;

og_service
:
   SERVICE name = variable NEWLINE og_service_tail*
;

og_service_tail
:
   ogs_description
   | ogs_group_object
   | ogs_service_object
;

og_user
:
   USER name = variable NEWLINE og_user_tail*
;

og_user_tail
:
   ogu_description
   | ogu_group_object
   | ogu_user
   | ogu_user_group
;

ogipa_host_info
:
   HOST_INFO IP_ADDRESS NEWLINE
;

ogipa_ip_addresses
:
   IP_ADDRESS+ NEWLINE
;

ogit_group_object
:
   GROUP_OBJECT name = variable NEWLINE
;

ogit_icmp_object
:
   ICMP_OBJECT icmp_object_type NEWLINE
;

ogn_group_object
:
   GROUP_OBJECT name = variable NEWLINE
;

ogn_network_object
:
   NETWORK_OBJECT ogn_network_object_tail
;

ogn_network_object_tail
:
   (
      prefix = IP_PREFIX
      | prefix6 = IPV6_PREFIX
      |
      (
         HOST
         (
            address = IP_ADDRESS
            | address6 = IPV6_ADDRESS
            | host = variable
         )
      )
      |
      (
         OBJECT name = variable
      )
      | host = variable
   ) NEWLINE
;

ogp_description
:
   description_line
;

ogp_group_object
:
   GROUP_OBJECT name = variable NEWLINE
;

ogp_protocol_object
:
   PROTOCOL_OBJECT protocol NEWLINE
;

ogs_description
:
   description_line
;

ogs_group_object
:
   GROUP_OBJECT name = variable NEWLINE
;

ogs_service_object
:
   (
      protocol
      |
      (
         OBJECT name = variable
      )
   ) NEWLINE
;

ogu_description
:
   description_line
;

ogu_group_object
:
   GROUP_OBJECT name = variable NEWLINE
;

ogu_user
:
   USER name = variable NEWLINE
;

ogu_user_group
:
   name = variable NEWLINE
;

on_description
:
   description_line
;

on_fqdn
:
   FQDN
   (
      V4
      | V6
   )? fqdn = variable NEWLINE
;

on_host
:
   HOST
   (
      address = IP_ADDRESS
      | address6 = IPV6_ADDRESS
   ) NEWLINE
;

on_nat
:
   NAT ~NEWLINE* NEWLINE // todo

;

on_range
:
   RANGE start = IP_ADDRESS end = IP_ADDRESS NEWLINE
;

on_subnet
:
   SUBNET
   (
      (
         address = IP_ADDRESS mask = IP_ADDRESS
      )
      | prefix6 = IPV6_PREFIX
   ) NEWLINE
;

os_description
:
   description_line
;

os_service
:
   SERVICE protocol NEWLINE //todo: change to os_service_typoe allowing tcp and udp port ranges

;

p2p_stanza
:
   P2P VARIABLE NEWLINE INTERFACE ~NEWLINE* NEWLINE INTERFACE ~NEWLINE* NEWLINE
;

peer_sa_filter
:
   SA_FILTER
   (
      IN
      | OUT
   )
   (
      LIST
      | RP_LIST
   ) name = variable NEWLINE
;

peer_stanza
:
   PEER IP_ADDRESS NEWLINE
   (
      null_block_substanza
      | peer_sa_filter
   )*
;

pim_accept_register
:
   ACCEPT_REGISTER
   (
      (
         LIST name = variable
      )
      |
      (
         ROUTE_MAP name = variable
      )
   ) NEWLINE
;

pim_accept_rp
:
   ACCEPT_RP
   (
      AUTO_RP
      | IP_ADDRESS
   ) name = variable NEWLINE
;

pim_null
:
   (
      AUTORP
      | BIDIR_ENABLE
      | BIDIR_OFFER_INTERVAL
      | BIDIR_OFFER_LIMIT
      | BSR_CANDIDATE
      | DM_FALLBACK
      | LOG_NEIGHBOR_CHANGES
      | REGISTER_RATE_LIMIT
      | REGISTER_SOURCE
      | SEND_RP_DISCOVERY
      | V1_RP_REACHABILITY
   ) ~NEWLINE* NEWLINE
;

pim_rp_address
:
   RP_ADDRESS IP_ADDRESS
   (
      OVERRIDE
      | name = variable
   ) NEWLINE
;

pim_rp_announce_filter
:
   RP_ANNOUNCE_FILTER
   (
      GROUP_LIST
      | RP_LIST
   ) name = variable NEWLINE
;

pim_rp_candidate
:
   RP_CANDIDATE interface_name
   (
      (
         GROUP_LIST name = variable
      )
      |
      (
         INTERVAL DEC
      )
      |
      (
         PRIORITY DEC
      )
   )+ NEWLINE
;

pim_send_rp_announce
:
   SEND_RP_ANNOUNCE interface_name SCOPE ttl = DEC
   (
      (
         GROUP_LIST name = variable
      )
      |
      (
         INTERVAL DEC
      )
   )+ NEWLINE
;

pim_spt_threshold
:
   SPT_THRESHOLD
   (
      DEC
      | INFINITY
   )
   (
      GROUP_LIST name = variable
   )? NEWLINE
;

pim_ssm
:
   (
      DEFAULT
      |
      (
         RANGE name = variable
      )
   ) NEWLINE
;

router_multicast_stanza
:
   ROUTER
   (
      IGMP
      | MLD
      | MSDP
      | PIM
   ) NEWLINE router_multicast_tail
;

router_multicast_tail
:
   (
      address_family_multicast_stanza
      | null_block_substanza
      | peer_stanza
   )*
;

s_class_map
:
   CLASS_MAP
   (
      MATCH_ALL
      | MATCH_ANY
   )? name = variable NEWLINE s_class_map_tail*
;

s_class_map_tail
:
   cm_end_class_map
   | cm_match
;

s_control_plane
:
   CONTROL_PLANE NEWLINE s_control_plane_tail*
;

s_control_plane_tail
:
   cp_ip_access_group
   | cp_ip_flow
   | cp_management_plane
   | cp_null
   | cp_service_policy
;

s_ip
:
   IP s_ip_tail
;

s_ip_tail
:
   ip_pim
;

s_line
:
   LINE ~NEWLINE* NEWLINE
   (
      l_access_class
      | description_line
      | null_block_substanza
      | null_block_substanza_full
      | unrecognized_line
   )*
;

s_management
:
   MANAGEMENT
   (
      CONSOLE
      | SSH
      | TELNET
   ) NEWLINE s_management_tail*
;

s_management_tail
:
   mgmt_ip_access_group
   | mgmt_null
;

s_ntp
:
   NTP s_ntp_tail
;

s_ntp_tail
:
   ntp_common
   |
   (
      NEWLINE ntp_common*
   )
;

s_object
:
   OBJECT s_object_tail
;

s_object_tail
:
   o_network
   | o_service
;

s_object_group
:
   OBJECT_GROUP s_object_group_tail
;

s_object_group_tail
:
   og_icmp_type
   | og_ip_address
   | og_network
   | og_protocol
   | og_service
   | og_user
;

srlg_interface_numeric_stanza
:
   DEC ~NEWLINE* NEWLINE
;

srlg_interface_stanza
:
   INTERFACE ~NEWLINE* NEWLINE srlg_interface_numeric_stanza*
;

srlg_stanza
:
   SRLG NEWLINE srlg_interface_stanza*
;

stanza
:
   appletalk_access_list_stanza
   | community_set_stanza
   | extended_access_list_stanza
   | hostname_stanza
   | interface_stanza
   | ip_as_path_access_list_stanza
   | ip_as_path_regex_mode_stanza
   | ip_community_list_expanded_stanza
   | ip_community_list_standard_stanza
   | ip_default_gateway_stanza
   | ip_prefix_list_stanza
   | ip_route_stanza
   | ipv6_router_ospf_stanza
   | ipx_sap_access_list_stanza
   | l2vpn_stanza
   | multicast_routing_stanza
   | mpls_ldp_stanza
   | mpls_traffic_eng_stanza
   | null_stanza
   | prefix_set_stanza
   | protocol_type_code_access_list_stanza
   | route_map_stanza
   | route_policy_stanza
   | router_bgp_stanza
   | router_isis_stanza
   | router_multicast_stanza
   | router_ospf_stanza
   | router_ospfv3_stanza
   | router_rip_stanza
   | router_static_stanza
   | rsvp_stanza
   | s_class_map
   | s_control_plane
   | s_ip
   | s_line
   | s_management
   | s_ntp
   | s_object
   | s_object_group
   | s_router_eigrp
   | standard_access_list_stanza
   | switching_mode_stanza
   | unrecognized_block_stanza
   | vrf_context_stanza
   | vrf_definition_stanza
;

switching_mode_stanza
:
   SWITCHING_MODE ~NEWLINE* NEWLINE
;

vrf_context_stanza
:
   VRF CONTEXT name = variable NEWLINE vrfc_stanza*
;

vrf_definition_stanza
:
   VRF DEFINITION? name = variable NEWLINE vrfd_stanza*
   (
      EXIT_VRF NEWLINE
   )?
;

vrfc_stanza
:
   ip_route_vrfc_stanza
;

vrfd_stanza
:
   address_family_vrfd_stanza
   | null_vrfd_stanza
;

xconnect_stanza
:
   XCONNECT GROUP VARIABLE NEWLINE p2p_stanza*
;
