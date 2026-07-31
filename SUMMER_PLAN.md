# Trail Eyes — Summer 2026 Intern Plan

**Goal:** finish migrating the Trail Eyes app onto the new backend, and get it into real
testers' hands. The hard product work is done — this summer is about *finishing and shipping*,
not building from scratch.

This doc is your orientation + checklist. Read the top three sections before the kickoff
meeting; the checklists are what you'll actually work through.

---

## What Trail Eyes is

A mobile app for reporting trail hazards in Forest Park, Portland. Hikers submit geolocated
reports (fallen tree, erosion, damaged sign, etc.) with a photo; the reports show up on a map.
It's a PSU research project (NSF-funded). The app is built in **Flutter** (Dart).

## The project has three repos — here's how they fit together

| Repo | What it is | Status |
|------|-----------|--------|
| `forest-park-reports-app` | **The Flutter mobile app** (this repo) | Mature; mid-migration |
| `trail-eyes-monorepo` | The **new backend + admin panel** (TypeScript). Live at `api.nightly.traileyes.net` | Active; ~80% of what the app needs |
| `forest-park-reports-server` | The **old ("legacy") backend** (Deno). Was `forestpark.cecs.pdx.edu`, now `legacy.traileyes.net` | Being retired; currently offline |

The app is **in the middle of moving from the legacy backend to the new one.** That migration
is the central task of the summer. Most of the recent app work lives on the branch
**`feature/server-migration`** — that's where you'll work, *not* `dev`.

## Where the migration actually stands (important)

The app currently talks to **two backends at once**:
- **Map, trails, hazard markers, styles** → already on the **new** backend (`api.nightly`). ✅
- **Submitting hazards, photos, trail elevation** → still on the **legacy** backend. ⬅️ *this is what's left*

The new backend already supports report submission, **photo upload/download**, trail data
(with elevation baked into the map geometry), and map styles. The remaining work is mostly on
the **app side**: point those last few features at the new backend and drop the legacy server.
(One small backend piece — an endpoint to change a report's status — is being added separately;
Dr. Lipor's helper "Claude" is providing that plus a worked code example for you to follow.)

> **Why this matters:** because a hazard is currently *written* to the legacy database but the
> map *reads* from the new one, a report you submit today won't appear on the map. Finishing the
> migration fixes that. It's the core loop, so it's priority one.

---

## Ground rules (how we work)

1. **Work on branches off `feature/server-migration`; open small pull requests.** Dr. Lipor
   reviews and merges. Never push straight to `dev` or `feature/server-migration`.
2. **One logical change per PR.** A giant "fix everything" PR is impossible to review.
3. **Finish and ship — don't gold-plate.** Resist rewriting things that already work. If a
   package works at a slightly newer version, bump it; don't upgrade everything at once.
4. **Stuck for ~30 min? Ask.** Post the exact error. Getting unblocked fast beats grinding.
5. **When something works, commit it.** Small, frequent commits with clear messages.
6. End of each week: post what you finished, what's blocked, what's next.

---

## Milestone 1 — Get the app building and running (Week 1)

This is your onboarding, and it's the prerequisite for everything else: you can't verify any
migration work until the app builds. It doesn't depend on anyone else.

- [ ] Install **Flutter** (latest stable) + **Android Studio** + Android SDK; set up an emulator
      or an Android phone with USB debugging. (`flutter doctor` green on the Android checks.)
- [ ] Clone this repo, then `git checkout feature/server-migration` (**not** `dev`)
- [ ] Get the `.env` file from Dr. Lipor and place it in the repo root (it has the API keys —
      including the Protomaps map key — that the app needs). Never commit it; it's gitignored.
- [ ] `flutter pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`  *(regenerates code; rerun after
      editing anything in `lib/model` or `lib/provider`)*
- [ ] `flutter run`
- [ ] Expect friction — this branch was last built ~2 years ago. Known risk: four dependencies
      come from forked git repos (`sliding_up_panel2`, `flutter_uploader`, `flutter_compass`,
      `icon_font_generator`). Fix build errors one dependency at a time.
- [ ] **Deliverable:** the app launches and the **map loads with trails** (that data comes from
      the live `api.nightly` backend). Submitting a hazard won't fully work yet — that's
      Milestone 2. Post a screenshot + notes on anything the setup steps missed.

---

## Milestone 2 — Finish the migration to the new backend (Weeks 2–5)

Point the last legacy-dependent features at the new backend. Claude will hand you **one feature
migrated end-to-end as a worked example** — you'll build the rest using it as a template, and
verify each on a real device. Rough map of what needs repointing (Claude will provide the
precise, per-file version):

- [ ] **Submit a hazard** — move from legacy `POST /hazard/new` to the new backend's report
      submission
- [ ] **Photo upload + download** — move to the new backend's image routes (`postImage`/`getImage`)
- [ ] **Hazard status / updates** — reconcile the old "hazard updates" flow to the new model,
      where a report just has a `status` (uses the new status endpoint Claude is adding)
- [ ] **Trail elevation graph** — read elevation from the new map geometry (it's already 3D)
      instead of the legacy binary trail format
- [ ] **Regenerate the API client** from the new backend's OpenAPI spec (`api/traileyes_api`)
- [ ] **Finish the map** — the new MapLibre + Protomaps vector map (`map_page_libre.dart`)
- [ ] Remove the legacy backend URL (`kApiUrl`) once nothing uses it
- [ ] **Deliverable:** submit a hazard with a photo → it appears on the map. Core loop works,
      entirely on the new backend.

*(Backend pieces — the status endpoint, endpoint hardening — are handled separately by Claude
and validated with Elliot on the Friday handoff call. You consume them; you don't have to build
them.)*

---

## Milestone 3 — Fix CI & Android beta distribution (Weeks 4–6)

- [ ] Fix the app's **GitHub Actions** workflow (it uses retired actions) so it builds a signed
      APK again
- [ ] Set up **Android beta distribution** — Firebase App Distribution (easiest; testers install
      from a link) or Google Play internal testing
- [ ] Write a 1-page **tester guide** (how to install, what to try, how to report bugs as GitHub
      Issues)
- [ ] **Deliverable:** a non-developer can install the app from a link on a real Android phone

## Milestone 4 — Test round & polish (Weeks 6–8)

- [ ] Confirm the app points at the right backend for real testers
- [ ] Smoke-test every core flow: map, submit hazard + photo, offline queue, status
- [ ] Recruit testers; triage GitHub Issues; fix the top bugs; ship updates
- [ ] **Deliverable:** real testers using it and filing feedback

---

## A couple of open decisions (Dr. Lipor owns these)

- **Base map:** the app currently uses Google satellite tiles via an unofficial URL in
  `lib/page/home_page/map_page.dart` — fine for dev, **not OK for public release**. The new
  MapLibre map uses Protomaps vector tiles (API key already in `.env`). Part of finishing the map.
- **Backend host for testing:** the new backend runs on `api.nightly` (auto-deployed from the
  monorepo). Whether "nightly" is good enough for real testers, or needs a separate prod, is a
  Dr. Lipor + handoff-call decision.

## Who does what

- **Interns:** Milestones 1–4 (app building, the migration repoint, distribution, testing).
- **Claude (Dr. Lipor's coding assistant):** the backend status endpoint + hardening, one
  worked migration example, the CI fix draft, and the detailed per-file migration checklist.
- **Dr. Lipor:** reviews/merges PRs, owns accounts/keys and the base-map/host decisions.
- **Elliot (original developer):** available through the **Friday handoff call** and briefly
  after — the person to ask about intent/history. Their time is limited, so batch questions.

## Definition of done for the summer

✅ The app builds from a clean checkout · ✅ It runs entirely on the new backend (submit a hazard
with photo → see it on the map) · ✅ CI produces a signed Android build · ✅ Real testers have it
installed and are filing feedback.

Anything past that (iOS/TestFlight — needs a Mac; the admin moderation panel; Play Store public
launch) is a bonus / next term.

## Glossary

- **Flutter / Dart** — the app's framework + language
- **`build_runner`** — regenerates auto-written `*.g.dart` files; rerun after editing models/providers
- **Backend / API** — the server the app talks to over the internet (holds the database)
- **Migration** — moving the app from the old (legacy) backend to the new one
- **CI** — the automated build that runs on GitHub when you push
- **APK** — an installable Android app file
- **Riverpod** — the app's state-management library (`lib/provider/`)
