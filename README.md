<p align="center">
 <img src="https://hsto.org/webt/kn/zm/ef/knzmeflejqqdsssb_uyg6_pzoio.png" width="120" alt="icon">
</p>

# Release tools (scripts)

[![Build][badge_automated]][link_hub]
[![Build][badge_build]][link_hub]
[![Docker Pulls][badge_pulls]][link_hub]
[![Issues][badge_issues]][link_issues]
[![License][badge_license]][link_license]

## What is this?

Docker image with scripts release making on different services.

## Supported tags

Tag name | Details                 | Full image name              | Dockerfile
:------: | :---------------------: | :--------------------------: | :--------:
`1.0`    | ![Size][badge_size_1_0] | `avto-dev/release-tools:1.0` | [link][dockerfile_1_0]

[badge_size_1_0]:https://images.microbadger.com/badges/image/512k/filebeat-udp-to-elastic:1.0.svg
[dockerfile_1_0]:https://github.com/512k/filebeat-udp-to-elastic-docker/blob/image-1.0/Dockerfile

## v1.0

### Tools

`changelog-to-gitlab-release.sh` - Make release on gitlab.com based on entry in `CHANGELOG.md` file.

```bash
$ docker run -ti -v $(pwd)/CHANGELOG.md:/CHANGELOG.md:ro \
    avtodev/release-tools:1.0 changelog-to-gitlab-release.sh \
      "./CHANGELOG.md" \                                  # Path to the CHANGELOG.md
      "v1.0.0" \                                          # Version header (for getting content from CHANGELOG.md)
      "v1.0.0" \                                          # Git tag name (must exists on target reporitory/project)
      "https://gitlab.com/api/v4/projects/666/releases" \ # Gitlab endpoint API uri
      "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"               # Auth token
```

`changelog-to-noticeable-post.sh` - Make post on [noticeable.io][noticeable_io] with content entry from `CHANGELOG.md` file.

```bash
$ docker run -ti -v $(pwd)/CHANGELOG.md:/CHANGELOG.md:ro \
    avtodev/release-tools:1.0 changelog-to-noticeable-post.sh \
      "./CHANGELOG.md" \                                  # Path to the CHANGELOG.md
      "v1.0.0" \                                          # Version header (for getting content from CHANGELOG.md)
      "John Doe" \                                        # Post author name
      "Application FooBar v1.0.0 Released" \              # Post title
      "https://hsto.org/webt/hn/5c/6g/hn5c6geloex3u6rzdphnguheckk.jpeg" \ # Featured image URI
      "New feature" \                                     # Post label name
      "XXXXXXXXXXXXXXXXXXXXX" \                           # Project ID
      "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"               # API key
```

### License

MIT. Use anywhere for your pleasure.

[noticeable_io]:https://noticeable.io
[badge_automated]:https://img.shields.io/docker/cloud/automated/512k/filebeat-udp-to-elastic.svg?style=flat-square&maxAge=30
[badge_pulls]:https://img.shields.io/docker/pulls/512k/filebeat-udp-to-elastic.svg?style=flat-square&maxAge=30
[badge_issues]:https://img.shields.io/github/issues/512k/filebeat-udp-to-elastic-docker.svg?style=flat-square&maxAge=30
[badge_build]:https://img.shields.io/docker/cloud/build/512k/filebeat-udp-to-elastic.svg?style=flat-square&maxAge=30
[badge_license]:https://img.shields.io/github/license/512k/filebeat-udp-to-elastic-docker.svg?style=flat-square&maxAge=30
[link_hub]:https://hub.docker.com/r/512k/filebeat-udp-to-elastic/
[link_license]:https://github.com/512k/filebeat-udp-to-elastic-docker/blob/master/LICENSE
[link_issues]:https://github.com/512k/filebeat-udp-to-elastic-docker/issues
[filebeat]:https://www.elastic.co/products/beats/filebeat
