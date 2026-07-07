# Migration Checklist — moving the app off the legacy backend

Companion to **Milestone 2** in [SUMMER_PLAN.md](SUMMER_PLAN.md). This is the precise, per-file
version: every place the app still calls the **legacy** backend (`kApiUrl` = `legacy.traileyes.net`),
and the **new** backend endpoint it should use instead (`api.nightly.traileyes.net`).

All line numbers are on branch **`feature/server-migration`** (verified 2026-07-07).

## Endpoint mapping (legacy → new)

| # | Legacy call (what the app does now) | New backend endpoint | Notes |
|---|-------------------------------------|----------------------|-------|
| 1 | `GET /hazard/active` — list active hazards | `GET /geojson/reports.json` (`geojson.getReports`) | A `geojson_provider` already fetches this. Reconcile `ActiveHazard` with it rather than keeping two paths. |
| 2 | `GET /hazard/{uuid}` — a hazard's update *history* | **No direct equivalent** | New model has a single `status` per report, not an update log. Needs a product decision (see Open Questions). |
| 3 | `POST /hazard/new` — submit a hazard | `POST /reports/report` (`reports.postReport`) | Body must match `ReportInsertSchema` (see Model reconciliation). |
| 4 | `PUT /hazard/image/{uuid}` — upload photo | `POST /reports/image/{imageUuid}` (`reports.postImage`) | **Method changes PUT → POST**, path prefix changes. Multipart `image` field. |
| 5 | `POST /hazard/update` — change a hazard's status | **status-update endpoint (being built by Claude)** | Endpoint lands on the new backend this week; consume it here. |
| 6 | `GET /hazard/image/{uuid}` — display photo | `GET /reports/image/{imageUuid}` (`reports.getImage`) | Update the image-display URL (see `hazard_image.dart`). |
| 7 | `GET /trail/all` — binary trails + elevation | `GET /geojson/routes.json` (`geojson.getRoutes`) | Elevation is the 3rd coordinate (geometry is 3D). Replaces the binary decode. |
| 8 | `GET /trail/relations` — trail connectivity | **Verify** — no relations endpoint found on new backend | Either add one, or confirm it's now computed client-side (turf). Ask Elliot. |

## Per-file task list

**`lib/provider/dio_provider.dart:10`** — `baseUrl: kApiUrl` (legacy).
- [ ] Once everything below is migrated, either repoint the dio base at the new backend or move
      these calls onto the generated client (`api/traileyes_api`). Do this **last**.

**`lib/provider/hazard_provider.dart`** — the bulk of the work:
- [ ] `:46` `ActiveHazard._fetch` → `GET /hazard/active` → use geojson reports (#1)
- [ ] `:109` `createHazard` → `POST $kApiUrl/hazard/new` → `reports.postReport` (#3)
- [ ] `:128` `createHazard` image → `PUT $kApiUrl/hazard/image/…` → `reports.postImage` (#4)
- [ ] `:~190` `HazardUpdates._fetch` → `GET /hazard/{uuid}` → reconcile update history (#2)
- [ ] `:212` `updateHazard` → `POST $kApiUrl/hazard/update` → new status endpoint (#5)
- [ ] `:231` `updateHazard` image → `PUT $kApiUrl/hazard/image/…` → `reports.postImage` (#4)

**`lib/provider/trail_provider.dart:~35`** — `Trails._fetch` → `GET /trail/all` (binary).
- [ ] Replace binary decode with the geojson routes path (#7). Note a `geojson_provider` already
      exists — likely `Trails` (binary) should be retired in favor of it. Confirm which is canonical.

**`lib/provider/relation_provider.dart`** — `GET /trail/relations`.
- [ ] Repoint or confirm client-side (#8, open question).

**`lib/page/home_page/panel_page/hazard_image.dart`** (and anywhere images are shown):
- [ ] Update the image URL to `GET /reports/image/{uuid}` (#6).

**Offline queue — `lib/util/offline_uploader.dart` + `lib/model/queued_request.dart`:**
- [ ] `createHazard`/`updateHazard` enqueue **full URLs** (`$kApiUrl/...`) into the offline
      uploader. Every enqueued URL above must be updated, and the PUT→POST method change (#4)
      threaded through `UploadMethod`. Test the offline path specifically (airplane mode → submit
      → reconnect → uploads).

**Regenerate the API client:**
- [ ] After the backend is final, regenerate `api/traileyes_api` from the new OpenAPI spec
      (`openapi_generator_config.json`) so the image routes are included.

## Model reconciliation (the tricky part)

The app's `HazardModel` / `HazardUpdateModel` must map onto the new backend's single `reports`
table (`ReportInsertSchema`). New fields: `creatorDeviceId`, `category`, `route`, `trail`,
`geometry` (3D point), `image`, `blurHash`, `status` (`open`/`confirmed`/`inProgress`/`closed`),
`localId`, `description`, `locationDescription`.
- [ ] Map `HazardModel.create(...)` output to those fields (e.g. `uuid` → `localId`, hazard type
      → `category`, `SnappedLatLng` → `route`/`trail` + geometry).
- [ ] Decide how the old "hazard update log" collapses into a single `status` (#2).

## Open questions for Elliot (Friday handoff)

1. **Trail relations** (#8): is there a new endpoint, or is connectivity now computed client-side?
2. **Update history** (#2): confirm the update-log is intentionally replaced by a single `status`
   — anything in the app that needs the full history?
3. **`Trails` (binary) vs `geojson_provider`**: which is the intended path for trail data going
   forward?
4. **Canonical database**: after cutover, everything is on the nightly DB — correct?

## Suggested build order

1. **Claude builds** the status-update endpoint (#5) on the backend + migrates **hazard
   submission + photo upload (#3, #4, #6)** end-to-end as the **worked example**.
2. Interns follow that pattern for the rest: trail data (#7), active hazards (#1), status/update
   (#5 on the app side), relations (#8).
3. Reconcile models as you go; regenerate the client; retire `kApiUrl` (dio base) last.
4. Full test: submit a hazard with a photo → it appears on the map, all on the new backend.
