# metalcloud-deployments

Desired state for MetalCloud Edge Devices. Vocabulary (Release, Device, Site, Stage,
Activate, Drift, …) is defined in `CONTEXT.md` of the Jetson Fleet repo; the decisions
behind this repo are its ADRs 0002–0004.

| Path | What it is |
|---|---|
| `fleet/devices.yaml` | Every Device: Site, environment, Tailscale hostname, SSH login |
| `sites/<site>/production.yaml` | The Site's Desired release (a one-line pointer) |
| `sites/<site>/…` | Compose file and non-secret site config that Releases reference by sha256 |
| `releases/<site>/<id>.yaml` | Release manifests. **Append-only**: never edit or delete one; make a new id |
| `builder-profiles/` | The machine an image must be built on (checked against image labels) |
| `runtime-profiles/` | How a Device runs Releases |

No secrets here, ever: passwords, SSH keys, API secrets, RTSP credentials and tokens live
on the Device in `/opt/metalcloud/persistent/secrets/`.

## Changing production

1. Build the image on a staging builder:
   `fleetctl edge build <builder> --repo <app checkout> --profile builder-profiles/<profile>.yaml`
   writes `release-build.json` (do not commit it).
2. `fleetctl edge new-release <site> <new-id> --from <current-id> --build release-build.json
   [--compose P] [--site-env P] [--model NAME=P] --note "..."` writes
   `releases/<site>/<new-id>.yaml` with every artifact re-hashed; it never overwrites.
   Changed compose/site.env files go in a new `sites/<site>/<release>/` folder.
3. `fleetctl edge validate --all` — must pass; it prints the real sha256 of any artifact
   whose hash is wrong.
4. Point `sites/<site>/production.yaml` at the new id, in a PR.
5. After review: `fleetctl edge doctor <device>` (read-only), then
   `fleetctl edge deploy <device>` (asks before activating), then `fleetctl edge drift`.

Run `fleetctl edge …` from this directory, or set `METALCLOUD_DEPLOYMENTS` to it.
