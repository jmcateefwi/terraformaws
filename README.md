
This repository contains a Terraform AWS deployment project that builds [IaaS as Code: Single VPC
with 3 subnets App, Dev, Web with multiple EC2 instances and load balancers].
The detailed description on each resource and configuration is found below. This is
designed to give a working example which can the basis for most traditional datacenter to cloud migration projects and can be altered to be more
complex.

## Usage

`terraform.tfvars` holds variables which should be overriden with valid ones.

### Plan

```
terraform plan -var-file terraform.tfvars
```

### Apply

```
terraform apply -var-file terraform.tfvars
```

### Destroy

```
terraform destroy -var-file terraform.tfvars
```
##  Overview
The following diagram shows the key components of the configuration for this scenario.

![Diagram](3tierArch.jpg)

The configuration for this package includes a virtual private cloud (VPC) with a public subnet and a private subnet. This is recommended if you want to run a public-facing web application, while maintaining back-end servers that aren't publicly accessible. All internal traffic is limited to each subnet with only remote administration ports (SSH, RDP) opened between them.  After this package is provisioned, the user must edit the security groups to allow the traffic needed for your solutions to navigate between subnets with your own custom ingress, egress rules. For example, you can set up security and routing so that the web servers can communicate with the database servers.

The instances in the public subnet can send outbound traffic directly to the Internet, whereas the instances in the private subnet can't. Instead, the instances in the private subnet can access the Internet by using a network address translation (NAT) gateway that resides in the public subnet. The database servers can connect to the Internet for software updates using the NAT gateway, but the Internet cannot establish connections to the database servers.

The configuration for this scenario includes the following:

A VPC with a size /22 IPv4 CIDR block (example: 10.0.0.0/22). This provides 1,022 private IPv4 addresses.

A public subnet with a size /24 IPv4 CIDR block (example: 10.0.1.0/24). This provides 256 private IPv4 addresses. A public subnet is a subnet that's associated with a route table that has a route to an Internet gateway.

The private subnets with a size /24 IPv4 CIDR block (example: 10.0.2.0/25 APP Subnet, 10.0.2.128/25 Bastion Subnet, and 10.0.3.0/24 Database Subnet). These provide 256 private IPv4 addresses for each /24 subnet, with the 10.0.2.0 network split to /25.

An Internet gateway. This connects the VPC to the Internet and to other AWS services.

Instances with private IPv4 addresses in the subnet range (examples: 10.0.0.5, 10.0.1.5). This enables them to communicate with each other and other instances in the VPC.

Instances in the public subnet with Elastic IPv4 addresses (example: 198.51.100.1), which are public IPv4 addresses that enable them to be reached from the Internet. The instances can have public IP addresses assigned at launch instead of Elastic IP addresses. Instances in the private subnet are back-end servers that don't need to accept incoming traffic from the Internet and therefore do not have public IP addresses; however, they can send requests to the Internet using the NAT gateway (see the next bullet).

A NAT gateway with its own Elastic IPv4 address. Instances in the private subnet can send requests to the Internet through the NAT gateway over IPv4 (for example, for software updates).

A custom route table associated with the public subnet is also created. This route table contains an entry that enables instances in the subnet to communicate with other instances in the VPC over IPv4, and an entry that enables instances in the subnet to communicate directly with the Internet over IPv4.

The main route table associated with the private subnet. The route table contains an entry that enables instances in the subnet to communicate with other instances in the VPC over IPv4, and an entry that enables instances in the subnet to communicate with the Internet through the NAT gateway over IPv4.

## Routing

In this scenario, the VPC wizard updates the main route table used with the private subnet, and creates a custom route table and associates it with the public subnet.

Additionally, all traffic from each subnet that is bound for AWS (for example, to the Amazon EC2 or Amazon S3 endpoints) goes over the Internet gateway. The database servers in the private subnet can't receive traffic from the Internet directly because they don't have Elastic IP addresses. However, the database servers can send and receive Internet traffic through the NAT device in the public subnet.

Any additional subnets that you create use the main route table by default, which means that they are private subnets by default. If you want to make a subnet public, you can always change the route table that it's associated with.

The following tables describe the route tables for this scenario.

Main route table
The first entry is the default entry for local routing in the VPC; this entry enables the instances in the VPC to communicate with each other. The second entry sends all other subnet traffic to the NAT gateway (for example, nat-12345678901234567).

| Destination	 |Target |
|----|:---|
|10.0.0.0/16 | local|
|0.0.0.0/0 | nat-gateway-id|

Custom route table
The first entry is the default entry for local routing in the VPC; this entry enables the instances in this VPC to communicate with each other. The second entry routes all other subnet traffic to the Internet over the Internet gateway (for example, igw-1a2b3d4d).

| Destination	 |Target |
|---|:---:|
|10.0.0.0/16 | local |
|0.0.0.0/0 | igw-id |

Routing for IPv6
If you associate an IPv6 CIDR block with your VPC and subnets, your route tables must include separate routes for IPv6 traffic. The following tables show the route tables for this scenario if you choose to enable IPv6 communication in your VPC.

Main route table

The second entry is the default route that's automatically added for local routing in the VPC over IPv6. The fourth entry routes all other IPv6 subnet traffic to the egress-only Internet gateway.

| Destination	 |Target |
|---|:---:|
|10.0.0.0/16 | local |
|2001:db8:1234:1a00::/56| local |
|0.0.0.0/0 | nat-gateway-id |
|::/0 | egress-only-igw-id |

Custom route table

The second entry is the default route that's automatically added for local routing in the VPC over IPv6. The fourth entry routes all other IPv6 subnet traffic to the Internet gateway.

| Destination	 |Target |
|---|:---:|
|10.0.0.0/16 | local |
|2001:db8:1234:1a00::/56 | local |
|0.0.0.0/0 | igw-id |
|::/0 | igw-id |

## Security
AWS provides two features that you can use to increase security in your VPC: security groups and network ACLs. Security groups control inbound and outbound traffic for your instances, and network ACLs control inbound and outbound traffic for your subnets. In most cases, security groups can meet your needs; however, you can also use network ACLs if you want an additional layer of security for your VPC. For more information, see Internetwork traffic privacy in Amazon VPC.

For scenario 2, you'll use security groups but not network ACLs. If you'd like to use a network ACL, see Recommended network ACL rules for a VPC with public and private subnets (NAT).

Your VPC comes with a default security group. An instance that's launched into the VPC is automatically associated with the default security group if you don't specify a different security group during launch. For this scenario, we recommend that you create the following security groups instead of using the default security group:

WebServerSG: Specify this security group when you launch the web servers in the public subnet.

DBServerSG: Specify this security group when you launch the database servers in the private subnet.

AppServerSG: Specify this security group when you launch the application servers in the private subnet.

BastionServerSG: Specify this security group when you launch the bastion servers in the private subnet.

The instances assigned to a security group can be in different subnets. However, in this scenario, each security group corresponds to the type of role an instance plays, and each role requires the instance to be in a particular subnet. Therefore, in this scenario, all instances assigned to a security group are in the same subnet.

The following table describes the recommended rules for the WebServerSG security group, which allow the web servers to receive Internet traffic, as well as SSH and RDP traffic from your network. The web servers can also initiate read and write requests to the database servers in the private subnet, and send traffic to the Internet; for example, to get software updates. Because the web server doesn't initiate any other outbound communication, the default outbound rule is removed.

| Inbound	 |Protocol | Port range | Comments |
|---|:---:|:---:|:----:|
|0.0.0.0/0 | TCP | 80 | Allow inbound HTTP access to the web servers from any IPv4 address. |
|0.0.0.0/0 | TCP |443 | Allow inbound HTTPS access to the web servers from any IPv4 address. |
|Your home network's public IPv4 address range | TCP | 22 | Allow inbound SSH access to Linux instances from your home network (over the Internet gateway). You can get the public IPv4 address of your local computer using a service such as http://checkip.amazonaws.com or https://checkip.amazonaws.com. If you are connecting through an ISP or from behind your firewall without a static IP address, you need to find out the range of IP addresses used by client computers. |
| Your home network's public IPv4 address range | TCP | 3389 | Allow inbound RDP access to Windows instances from your home network (over the Internet gateway). |

Outbound

| Destination	 |Protocol | Port range | Comments |
|---|:---:|:---:|:----:|
| The ID of your DBServerSG security group | TCP | 1433 | Allow outbound Microsoft SQL Server access to the database servers assigned to the DBServerSG security group. |
| The ID of your DBServerSG security group | TCP | 3306 | Allow outbound MySQL access to the database servers assigned to the DBServerSG security group. |
| 0.0.0.0/0 | TCP | 80 | Allow outbound HTTP access to any IPv4 address. |
| 0.0.0.0/0 | TCP | 443 | Allow outbound HTTPS access to any IPv4 address. |

The following table describes the recommended rules for the DBServerSG security group, which allow read or write database requests from the web servers. The database servers can also initiate traffic bound for the Internet (the route table sends that traffic to the NAT gateway, which then forwards it to the Internet over the Internet gateway).

Inbound
| Inbound	 |Protocol | Port range | Comments |
|---|:---:|:---:|:----:|
|The ID of your WebServerSG security group | TCP | 1433 |Allow inbound Microsoft SQL Server access from the web servers associated with the WebServerSG security group.|
|The ID of your WebServerSG security group | TCP | 3306 | Allow inbound MySQL Server access from the web servers associated with the WebServerSG security group. |

Outbound

| Destination	 |Protocol | Port range | Comments |
|---|:---:|:---:|:----:|
|0.0.0.0/0 | TCP | 80 | Allow outbound HTTP access to the Internet over IPv4 (for example, for software updates). |
|0.0.0.0/0 | TCP | 443 | Allow outbound HTTPS access to the Internet over IPv4 (for example, for software updates).|

(Optional) The default security group for a VPC has rules that automatically allow assigned instances to communicate with each other. To allow that type of communication for a custom security group, you must add the following rules:

Inbound
| Inbound	 |Protocol | Port range | Comments |
|---|:---:|:---:|:----:|
|The ID of the security group | All | All | Allow inbound traffic from other instances assigned to this security group.|

Outbound
| Destination	 |Protocol | Port range | Comments |
|---|:---:|:---:|:----:|
|The ID of the security group |	All	| All |	Allow outbound traffic to other instances assigned to this security group.|

(Optional) If you launch a bastion host in your public subnet to use as a proxy for SSH or RDP traffic from your home network to your private subnet, add a rule to the DBServerSG security group that allows inbound SSH or RDP traffic from the bastion instance or its associated security group.

# terraform-aws-vpc
# terraform-aws-ec2
# terraform-aws-elb
# terraform-aws-eip
# terraform-aws-security_groups

Note


[Terraform]: http://terraform.io
[scenario_two]: http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html
[AWS documentation]: http://aws.amazon.com/documentation/
