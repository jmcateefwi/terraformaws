resource "aws_vpc_dhcp_options" "jmtest" {
    domain_name = "var.DnsZoneName"
    domain_name_servers = ["AmazonProvidedDNS"]
    tags = {
      Name = "My internal name"
    }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id = "jmtest"
    dhcp_options_id = "jmtestdhcp"
}

/* DNS PART ZONE AND RECORDS */
resource "aws_route53_zone" "main" {
  name = "main.internal"
  comment = "Managed by terraform"
}

resource "aws_route53_record" "database" {
   zone_id = "aws_route53_zone.main.internal"
   name = "mydatabase.var.DnsZoneName"
   allow_overwrite = true
   type = "A"
   ttl = "300"
   records = [
        "${aws_route53_zone.main.name_servers.0}",
        "${aws_route53_zone.main.name_servers.1}",
        "${aws_route53_zone.main.name_servers.2}",
        "${aws_route53_zone.main.name_servers.3}",
      ]
 }
