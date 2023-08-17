# openresty-proxy

## What is it?

This is a fork of [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) project *(automated nginx proxy for Docker containers)*
 with `nginx` replaced by `openresty` (`nginx` + `lua`).

The main idea to introduce `openresty` here is to add some support for "active health checks" in `nginx-proxy`
without changing the way the project works.

"Active health checks" are not supported in the `nginx` opensource version but can be emulated with the following `openresty` module: 

https://github.com/openresty/lua-resty-upstream-healthcheck
