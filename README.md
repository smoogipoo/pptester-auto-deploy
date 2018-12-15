# pptester auto deploy script

A small script which auto-deploys a dockerized instance of osu!web [built for difficulty + pp calculation](https://github.com/smoogipoo/osu-web/tree/pp-tester).

## Requirements

- docker (latest)
- docker-compose (latest)
- [Database dumps](https://data.ppy.sh) placed in `./sql`
- [Beatmap dumps](https://data.ppy.sh) placed in `./beatmaps`
- nginx, with the user having write permissions to `/etc/nginx/sites-enabled`

## Usage

1. Adjust `ports.dat` to a desired starting port. This port is mapped to port `80` in the dockerized instances.
2. Adjust `((YOUR-DOMAIN-HERE))` in `nginx.tpl` to point to the domain of your choice.  
  **Note:** Do NOT edit the `{DOMAIN}` or `{PORT}` fields.
3. Create a directory with the desired **sub**domain name.
4. Set variables listed below, as desired.
5. Run the script in the directory previously created.

## Known issues
- Running docker commands manually requires a UID. This can be resolved by `export UID`.
- The ES indexer runs immediately after the pp calculator starts. Just find the container via `docker container ls` and kill it.
- The ES indexer does not run after the pp calculator exits. Run it via `docker-compose up -d esindexer` after the pp calculator exits.

## Re-running

The calculators can be re-run without deploying new instances. Adjust the `osu-performance`, `osu-server`, and `osu-server/osu` repos to point the new repo HEADs, and run the following:

```
docker-compose up ((container here))
```

Where `((container here))` is one of the following:  
```
ppcalc
diffcalc
```

Afterwards, run `docker-compose up -d esindexer`.

## Variables

- `PP_REPO` - The [osu!performance](https://github.com/ppy/osu-performance) repository to use. E.g. `ppy/osu-performance`.
- `PP_BRANCH` - The [osu!performance](https://github.com/ppy/osu-performance) branch to use. E.g. `ppy/master`.
- `OSU_SERVER_REPO` - The [osu!server](https://github.com/ppy/osu-server) repository to use. E.g. `ppy/osu-server`.
- `OSU_SERVER_BRANCH` - The [osu!server](https://github.com/ppy/osu-server) branch to use. E.g. `ppy/master`.
- `OSU_REPO` - The [osu!](https://github.com/ppy/osu) repository to use. E.g. `ppy/osu`.
- `OSU_BRANCH` - The [osu!](https://github.com/ppy/osu) branch to use. E.g. `ppy/master`.
- `ES_REPO` - The [osu!es-indexer](https://github.com/ppy/osu-elastic-indexer) repository to use. E.g. `ppy/osu-elastic-indexer`.
- `ES_BRANCH` - The [osu!es-indexer](https://github.com/ppy/osu-elastic-indexer) branch to use. E.g. `ppy/master`.
- `WEB_REPO` - The [osu!web](https://github.com/ppy/osu-web) repository to use. E.g. `ppy/osu-web`.
- `WEB_BRANCH` - The [osu!web](https://github.com/ppy/osu-web) branch to use. E.g. `ppy/master`.  
  **Note**: The branch must be compatible with [smoogipoo/pp-tester](https://github.com/smoogipoo/osu-web/tree/pp-tester).