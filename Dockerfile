from  elixir:1.12-alpine as builder
run apk add --no-cache nodejs yarn git build-base
copy . .
env MIX_ENV="qa"
env RELEASE_CONFIG_DIR="/ret"
env RELEASE_MUTABLE_DIR="/ret/var"
env LC_ALL="en_US.UTF-8 LANG=en_US.UTF-8"
env REPLACE_OS_VARS="true"

run mix local.hex --force && mix local.rebar --force && mix deps.get
run mix deps.clean mime --build && rm -rf _build && mix compile
run mix distillery.release
run cp ./rel/config.toml ./_build/qa/rel/ret/config.toml
# run cp ./rel/config.toml ./_build/turkey/rel/ret/config.toml

from alpine
run mkdir -p /storage && chmod 777 /storage
workdir ret
copy --from=builder /_build/qa/rel/ret/ .
run apk update && apk add --no-cache bash openssl-dev openssl jq libstdc++
entrypoint ["/ret/bin/ret", "foreground"]
#/ret/bin/ret foreground
