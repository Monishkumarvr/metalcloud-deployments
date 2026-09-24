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

1. Add `releases/<site>/<new-id>.yaml` (artifact paths are relative to this repo root).
2. `fleetctl edge validate --all` — must pass; it prints the real sha256 of any artifact
   whose hash is wrong.
3. Point `sites/<site>/production.yaml` at the new id, in a PR.
4. After review: `fleetctl edge deploy <device>` (asks before activating), then
   `fleetctl edge drift`.

Run `fleetctl edge …` from this directory, or set `METALCLOUD_DEPLOYMENTS` to it.
