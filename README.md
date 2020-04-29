# Cloudflare IPs Monitoring

Monitor Cloudflare IP range for changes and auto-update configs for various services.

> :warning: **WARNING**: This container is no longer in active development. Consider using alternatives.

Cloudflare IP range does not change too frequently. Nevertheless, Cloudflare recommends monitoring that list on a regular basis.
This container monitors Cloudflare IP range for changes and auto-updates configuration of several services.
Currently, these services are supported:

- **nginx** (*set_real_ip_from*, *real_ip_header* directives)
- **nftables** (*tcp dport https ip saddr CLOUDFLARE_IP counter accept* directive)
- **iptables** (both ipv4 and ipv6)

## Usage

Here is a basic snippet to help you get started creating a container.

```
docker run -dit --restart unless-stopped \
    --name cloudflare-ips \
    -v </path/to/config/dir>:/opt/cloudflare-ips \
    -e CF_INTERVAL=300 \
    -e PUID=1000 \
    -e PGID=1000 \
    llamaq/cloudflare-ips
```

## License

This container and its code is licensed under the MIT License and provided "AS IS", without warranty of any kind.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
