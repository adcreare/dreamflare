# Dreamflare

A ruby based tool to replicate and keep in sync DNS records from Dreamhost to CloudFlare

## Why do I need this?
Dreamhost supports a native integration with CloudFlare for a very cost effective price. However this service has one major notable issue:

**It does not protect your zone apex record of your site  (mysite.com for example). It will only protect a CNAME of your site such as www.mysite.com**

This works ok if you only want to leverage the caching and performance optimizations CloudFlare offers.
It however it renders useless the web application firewall and DDOS mitigation capabilities.

If an attacker was to target your site they could completely bypass CloudFlare's protection by simply targeting the unprotected *mysite.com* instead of the protected *www.mysite.com*

If your site is currently protected in this way, you can see issue yourself how broken this configuration is by simply doing an *nslookup mysite.com* and comparing that to an *nslookup www.mysite.com*.

The first nslookup will return records that point to your Dreamhost server and only the second nslookup will return CloudFlare protected records. Thereby making it trivial for an attacker to bypass CloudFlare's protection.

It's madness that this is the default option when enabling the CloudFlare service under Dreamhost and I would strongly suggest against it despite the cheapness.

If you setup CloudFlare yourself, it will need to manage your DNS zone completely. CloudFlare do a good job of identifying what records to migrate over from Dreamhost.

Updates however are a problem. If Dreamhost move to you another server (and they do this often) your DNS in CloudFlare will still be pointing at the previous Dreamhost server. Your site will then be unreachable from the public internet thereby giving you a outage.

This tool is designed to be run on a regular interval every few minutes. It will download your current DNS configuration from Dreamhost and match it to the configuration in CloudFlare. If records are missing it will create them. If records have incorrect values it will update them.

For records that have multiple values (like MX records) it will ensure all the records match and remove any that do not.

In addition it will allow any single A or CNAME records created manually in CloudFlare to remain as long as they do not conflict with a record in DreamHost. Thereby allowing additional records to be created in CloudFlare for other purposes.

---

## Installation and Usage instructions

Dreamflare requires the ruby runtime, however it is very flexible to which ruby runtime. It was developed on ruby > 2.0 however it should work in older versions.

1. Download the gem file

2. Install the gem with ```gem install dreamflare-*.gem```

3. Create configuration in ~/.dreamflare/config.rb
```ruby
SearchZone = 'mysite.com' # the DNS zone name. This needs to be the apex record. no www.mysite.com etc
DHKEY  = "xxxxxxxx" # dreamhost API key
CFKEY = 'xxxxxxxxx' # CloudFlare API key
CFEMAIL = 'xxxxx@xxxxx.com' # CloudFlare account Email (required for API access)
CFZoneID = 'afxxxxxxxxxxxxxxxxx' # The unique ID that CloudFlare gives your zone
```

4. Replicate and sync by running the command ```dreamflare```

5. Schedule as a cron job or similar

---

## Development

DreamFlare is currently still under development.

I've designed the tool to be somewhat portable for other hosting providers, however at this time DreamHost -> CloudFlare is the only working operation.

 I won't be writing support personally for other providers but I do intend to document exactly what data objects the Compare_Zones.rb class expects to be able to perform the comparison.
