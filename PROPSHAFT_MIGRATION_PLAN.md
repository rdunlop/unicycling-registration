# Sprockets → Propshaft Migration Plan

**Status**: Deferred — for future implementation  
**Date prepared**: 2026-07-22  
**Scope**: Full migration from Sprockets-based asset pipeline to Propshaft + importmap-rails (modern Rails 7/8 default)

---

## Executive Summary

This app currently uses Sprockets as its asset pipeline, paired with importmap-rails for JavaScript module management. Propshaft is the modern, purpose-built asset pipeline for use with importmap-rails in Rails 7.1+, and is the Rails-recommended approach for new applications.

**Why migrate?**
- Propshaft is the Rails core team's official default and will receive long-term maintenance while Sprockets is in maintenance mode.
- Propshaft is simpler: no asset-pipeline directives (`//= require`, manifest files), no precompile lists, no compressor/compiler configuration — all files under load paths are auto-discovered and served/digested uniformly.
- Propshaft integrates seamlessly with importmap-rails; the current Sprockets+importmap pairing requires workarounds (explicit precompile lists, `assets.paths` configuration, the `javascript_importmap_tags` helper resolvingcompiled paths).
- Cleaner deployment: no `config.assets.*` configuration needed, reducing configuration surface area.

**Why not migrate now?**
- Sprockets is stable and working (after the precompile-list fix in commit be8562928).
- Migration has 5 distinct blockers requiring careful work: legacy JS dependency replacement, vendor gem compatibility, CSS compilation tool swap, wicked_pdf asset path adaptation, and manifest file removal.
- The immediate staging/feature blocker (Stimulus controller 404) is fixed with a simple precompile-list adjustment; migration is not required.
- This is multi-phase work suitable for a separate initiative/PR, not a blocking urgency.

---

## Current State (Sprockets)

### Gemfile/Dependencies

**Asset pipeline**:
- `sprockets ~> 4.0` (direct, line 8)
- `sprockets-rails` (transitive from `sassc-rails`)
- `importmap-rails` 1.1.6 (line 38)
- `sassc-rails` (line 68) — Sass compiler, hard-depends on Sprockets; **will not work with Propshaft**

**Asset-vendoring gems** (rely on Sprockets' `//= require` mechanism and must be replaced or manually vendored):
1. `foundation-rails` 6.6.2.0 — Foundation CSS/JS framework; provides SCSS + JS via Sprockets load path
2. `jquery-rails` 4.6.1 — provides jQuery via Sprockets
3. `jquery-datatables-rails` — depends on `sass-rails` + `jquery-rails`; ships JS/CSS via Sprockets
4. `select2-rails` — ships JS/CSS via Sprockets
5. `fancybox2-rails` (GitHub fork) — ships JS/CSS via Sprockets

**Related**:
- `cocoon` — nested forms; includes JS/CSS via Sprockets
- `wicked_pdf` — PDF rendering; resolves stylesheets to filesystem paths for wkhtmltopdf (needs verification against Propshaft asset resolution)

### Asset Structure

**CSS/Sass** (`app/assets/stylesheets/`, 58 `.scss` files + 5 pre-built `.css`):
- Theme files: `base_blue_pink.scss`, `base_blue_purple.scss`, `base_green_blue.scss`, `base_purple_blue.scss`
- Each theme has a `_split2.css` sibling (pre-compiled variants)
- Main files: `application.scss`, `foundation_and_overrides.scss`, `pdf.scss`
- Partials: `common/` (17 files), `new_styles/` (24 numbered files, color vars)
- Uses `@import` with explicit relative paths (e.g. `@import "common/printing"`) — standard Sass imports, not Sprockets-specific, but may need conversion to `@use`/`@forward` for modern Dart Sass eventually (lower priority)
- No `asset-url` / `image-url` / `font-url` Sass helpers in code (good — no Sprockets-in-Sass coupling)

**JavaScript** (two separate stacks, partially migrated):
- Legacy Sprockets stack: `app/assets/javascripts/application.js` — ~40 `//= require` directives pulling jQuery, Foundation, DataTables, Select2, Fancybox, Cocoon, datetimepicker, + ~20 in-house JS files (`attending.js`, `competitors.js`, `payments.js`, `lane_assignment.js`, etc.)
- **Critical finding**: No `javascript_include_tag("application")` found anywhere in real app views; this Sprockets manifest appears **orphaned/dead code**. `app/views/layouts/application.html.haml` only includes `javascript_include_tag "trix"` and relies on `javascript_importmap_tags` (which pins only `application`, Stimulus, `controllers/*`, `trix`, `@rails/actiontext` per `config/importmap.rb`). Git history shows recent edits to this file (e.g. "Replace jQuery UI sortable with SortableJS"), so **before deleting this file, verify with team whether any legacy JS paths still use it** — this is the single largest piece of Sprockets-only code in the app.
- Modern importmap stack: `app/javascript/application.js`, `controllers/`, `vendor/` (fancybox.js, jquery.are-you-sure.js, jquery.placeholder.js — duplicates of Sprockets-bundled libs, suggesting partial migration)

**Images/Fonts** (`app/assets/images/`, `app/assets/fonts/`):
- Images subdirectory + `screenshots/` subdir
- 14 font files (OpenSans family, ipag/ipagp ttf, license/readme)

**Manifest** (`app/assets/config/manifest.js`):
- Sprockets-specific file using `link_tree` directives to explicitly mark CSS theme files, fonts, images as precompile targets
- **Must be deleted for Propshaft** (Propshaft serves everything under load paths automatically)

### Configuration

**`config/initializers/assets.rb`** (after precompile-list fix):
```ruby
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += Dir.glob("app/javascript/controllers/**/*.js").map { |f| f.sub("app/javascript/", "") }
```

**`config/environments/production.rb`**:
- `config.assets.css_compressor = :sass`
- `config.assets.compile = false` (no fallback; strict precompile-only mode)
- `config.assets.digest = true`

**`config/environments/development.rb`**:
- `config.assets.debug = true`
- `config.assets.quiet = true`

**`config/environments/test.rb`**:
- `config.assets.raise_runtime_errors = true`

**`config/importmap.rb`**:
```ruby
pin "application", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
```

---

## Blockers & Required Changes

### 1. **Sass Compiler Replacement** (Required)

**Blocker**: `sassc-rails` (line 68, Gemfile) hard-depends on Sprockets and will not work with Propshaft. It pulls in `sprockets-rails` transitively.

**Solution**: Replace with `dartsass-rails` (the Rails-official Dart Sass compiler, pure Ruby wrapping the Dart Sass binary; no Sprockets dependency).

**Tasks**:
- Remove `sassc-rails` from Gemfile
- Add `gem 'dartsass-rails'`
- Run `bundle update`
- Test locally: `docker-compose run --rm app bundle exec rails assets:precompile` should compile SCSS → CSS without errors

**Impact**: Minimal. The SCSS code itself doesn't change; just the compiler. `dartsass-rails` requires `@use`/`@forward` syntax for Sass modules instead of `@import` (which is deprecated in Dart Sass), but:
- Most of the app's SCSS uses relative `@import "common/printing"` style imports, which Dart Sass still supports in the short term (deprecated but not removed as of Dart Sass 1.7)
- Plan for a separate Sass import refactor as a follow-up PR if strict Dart Sass warnings appear during precompile

**Estimated effort**: 1–2 hours (test coverage, verify no compilation errors)

---

### 2. **Legacy JavaScript Audit & Replacement** (Required, High Effort)

**Blocker**: `app/assets/javascripts/application.js` and ~40 `//= require` directives cannot be ported directly to Propshaft. All required files must be explicitly imported via ES6 `import` statements or pinned in `config/importmap.rb`.

**Current unknowns**:
- Is `app/assets/javascripts/application.js` actually loaded anywhere in the app? (Earlier search found zero `javascript_include_tag("application")` calls in views, suggesting it's dead code.)
- Which of the ~20 in-house JS files (attending.js, competitors.js, payments.js, lane_assignment.js, etc.) are still actively used vs. orphaned?

**Tasks**:
1. **Audit** (`~2 hours`):
   - For each file in `app/assets/javascripts/`:
     - Search the codebase for calls to its functions, selectors, data-attributes
     - Determine if the file is live or dead code
     - If live: understand its dependencies (e.g., does it depend on jQuery, Foundation, specific page context?)
   - Answer: Is `application.js` still loaded? Check if Sprockets-compiled JS is served at all currently.

2. **Classify** (`~2 hours`):
   - Group files into:
     - **Dead code** (no references): mark for deletion
     - **Live, high-value refactor** (e.g., payment flows, core interaction): plan for modern import/Stimulus refactor
     - **Live, low-priority** (edge-case utility): plan for vendoring as-is under `app/javascript/vendor/`

3. **Replace/Vendor** (`~10–20 hours`):
   - Dead code: delete and test
   - Low-priority live code: move to `app/javascript/vendor/` and manually import via `import` in `application.js`
   - High-priority: refactor to Stimulus controllers or modern ES6 modules (beyond scope of this plan; note for team)

**Note**: The partial duplication visible in `app/javascript/vendor/` (fancybox.js, jquery.are-you-sure.js, jquery.placeholder.js already vendored) suggests this process has already begun — prioritize understanding what's been done and what's left.

**Estimated effort**: 15–25 hours (heavily dependent on how much code is dead vs. live)

---

### 3. **Asset-Vendoring Gems Replacement** (Required, Medium Effort)

**Blocker**: Five gems (`foundation-rails`, `jquery-rails`, `jquery-datatables-rails`, `select2-rails`, `fancybox2-rails`) ship JavaScript and CSS specifically for Sprockets' load-path/require mechanism. Propshaft doesn't process `//= require` directives, so these gems' assets won't be automatically included.

**Options per gem**:

1. **`foundation-rails` (Framework CSS/JS)**:
   - **Option A**: Switch to npm `foundation-sites` package via Propshaft + importmap pin
     - `npm add foundation-sites` (or equivalent in this app's JS dependency setup)
     - Pin in `config/importmap.rb`: e.g. `pin "foundation", to: "@npm/foundation-sites"`
     - Replace `@import "foundation_and_overrides"` in SCSS with explicit imports/pins for needed Foundation modules
     - Effort: **5–8 hours** (verify CSS-only vs. JS-module dependencies)
   - **Option B**: Vendor manually from `node_modules` if already installed
     - Effort: **2–3 hours**

2. **`jquery-rails` (jQuery)**:
   - **Option A**: Replace with `jsDelivr` CDN pin or npm package
     - Pin in importmap: `pin "jquery", to: "@npm/jquery@latest"`
     - Effort: **1–2 hours**
   - **Option B**: Vendor manually
     - Effort: **1 hour**
   - **Note**: Foundation and DataTables both depend on jQuery; ordering matters for Stimulus controller initialization

3. **`jquery-datatables-rails` (DataTables widget)**:
   - **Option A**: Replace with npm `datatables.net` + adapters
     - Pin: `pin "datatables", to: "@npm/datatables.net"`
     - Import in JS: `import DataTable from "datatables"`
     - Import CSS: how to handle? (Propshaft doesn't auto-include CSS from JS imports; may need explicit stylesheet_link_tag or manual CSS vendoring)
     - Effort: **5–8 hours** (CSS inclusion, jquery.dataTables.foundation.js adapter)
   - **Option B**: Vendor from npm + vendored CSS
     - Effort: **3–5 hours**

4. **`select2-rails` (Select2 picker widget)**:
   - **Option A**: Replace with npm `select2` package
     - Pin: `pin "select2", to: "@npm/select2"`
     - Import CSS manually (stylesheet_link_tag or vendor CSS file)
     - Effort: **4–6 hours**
   - **Option B**: Vendor from npm
     - Effort: **2–3 hours**

5. **`fancybox2-rails` (Image lightbox, GitHub fork)**:
   - **Option A**: Switch to modern fork/maintained package (e.g. `Fancybox 3` or `Photoswipe`)
     - Effort: **6–10 hours** (includes verifying all page uses are compatible)
   - **Option B**: Vendor current fancybox2 code manually
     - Effort: **2–3 hours**
   - **Note**: `app/javascript/vendor/fancybox.js` already exists; determine if it's in use or vendoring is already partial

**Approach**: Option B (manual vendoring) for all is the lowest-risk, lowest-effort path; ensures no behavioral changes. Once Propshaft is stable, the team can gradually upgrade each gem to its npm equivalent and modern APIs in separate PRs.

**Estimated effort**: **12–20 hours** (depending on choice of option per gem and actual usage patterns found in step 2)

---

### 4. **CSS Asset References in PDF Layouts** (Verification Required)

**Blocker**: `wicked_pdf_stylesheet_link_tag` (used in `app/views/layouts/pdf.html.haml`, `pdf.pdf.haml`, `simple_pdf.html.haml`) resolves stylesheet logical names to **absolute filesystem paths** for wkhtmltopdf consumption. Propshaft's asset resolution and `public/` output structure differ from Sprockets' approach.

**Verification tasks** (`~2 hours`):
1. Check `wicked_pdf` gem version and its integration with Sprockets helpers
2. Test locally after Propshaft migration: does `rails generate controller test_pdf` + `wicked_pdf_stylesheet_link_tag` still resolve paths correctly?
3. If needed: adapt `wicked_pdf` configuration (e.g., `WickedPdf.config = { exe_path: ... }`) or replace with newer PDF gem if `wicked_pdf` incompatibility is confirmed

**Estimated effort**: 2–3 hours (minimal if compatible; larger if gem replacement needed)

---

### 5. **Manifest File Removal & Load Path Configuration** (Required, Low Effort)

**Blocker**: `app/assets/config/manifest.js` (Sprockets `link_tree` directives) has no Propshaft equivalent.

**Tasks**:
- Delete `app/assets/config/manifest.js`
- Add Propshaft load paths to `config/environments/production.rb` (or Rails.application.config during initialization):
  ```ruby
  config.assets.paths << Rails.root.join("app/assets/stylesheets")
  config.assets.paths << Rails.root.join("app/assets/images")
  config.assets.paths << Rails.root.join("app/assets/fonts")
  config.assets.paths << Rails.root.join("app/javascript")
  config.assets.paths << Rails.root.join("vendor/javascript")
  ```
  (Propshaft defaults to `app/assets`, `vendor/assets`, and `public` if not configured; explicit paths ensure all directories are included.)

**Estimated effort**: **1 hour**

---

## JavaScript Library Migration to Importmap (Pre-Propshaft Groundwork)

**Note**: The following sequences can be executed incrementally before the full Propshaft migration in Phase 2, allowing early validation and reducing the scope of Phase 5 (Legacy JS Refactoring) when it runs.

### Overview: Two categories of JavaScript to migrate

**Category A: Gem-vendored third-party libraries** — `jquery_ujs`, `dataTables` + `.foundation` adapter, `sortablejs`, `select2` + locale files, `fancybox`, `cocoon`, `jquery.are-you-sure`, `datetimepicker`. These are UMD/self-attaching files currently pulled via `//= require` in `legacy_application.js`, resolvable via Sprockets' gem load paths.

**Category B: First-party in-house files** — `attending.js`, `block_displayer.js`, `competitors.js`, `payments.js`, `lane_assignment.js`, `flash_highlight.js`, `reorder_rows.js`, etc. (~20 files). Currently rely on Sprockets concatenation for implicit shared scope; need explicit `import`/`export` conversion.

### Precompile list maintenance (required for all importmap pins in production/staging)

**Key insight**: When `config.assets.compile = false` (production/staging), Sprockets only compiles files explicitly on the precompile list. `importmap-rails` adds load paths (so pinned files can be **found**) but does not auto-add them to the precompile list.

**Action**: In `config/initializers/assets.rb`, add any gem-resolved pins to the precompile list:
```ruby
# Gem-vendored assets resolved via importmap must be explicitly precompiled
Rails.application.config.assets.precompile += %w[jquery.js foundation.js]
```

As new libraries are pinned, add their `.js` filenames to this list. (CDN-pinned libraries with `to: "https://..."` do not require precompile entries — the browser fetches the URL directly, not via Sprockets.)

### Migration sequence for Category A (gem-vendored libraries)

**Per-library steps**:

1. **Choose a library with no cross-library ordering dependency** (e.g., start with `sortablejs`, `cocoon`, or `jquery.are-you-sure` before `select2`+locales or `dataTables`+adapter).

2. **Pin the library**:
   ```bash
   bin/importmap pin <name>
   ```
   This resolves the library (either locally via gem Sprockets paths, or to a CDN URL if not found locally) and adds it to `config/importmap.rb`. If the resulting `to:` value is a CDN URL (`https://...`), the library will load from the CDN at runtime — no vendoring step needed. If it's a local Sprockets path (`/assets/...`), the file is served from Sprockets' compiled assets.

3. **Add the import** to `app/javascript/application.js`, in **the same relative order** the old `//= require` lines had (order matters for libraries with dependencies):
   ```js
   import "<name>"
   ```

4. **Add to the precompile list** (if the resulting `to:` is local, not a CDN URL):
   ```ruby
   Rails.application.config.assets.precompile += %w[<filename>.js]
   ```

5. **Remove the `//= require` line(s)** from `app/assets/javascripts/legacy_application.js`.

6. **Test** the specific UI that library drives (select2 dropdowns, sortable tables, fancybox lightbox, cocoon add/remove, are-you-sure dirty-form warning).

7. **Commit** — one library per commit for review clarity.

**Order recommendation**:
- First: single, standalone libraries with no other dependencies (`sortablejs`, `cocoon`, `jquery.are-you-sure`, `jquery.placeholder`, `datetimepicker`).
- Next: paired/ordered libraries (`select2` + 8 locale files — import in language order; `dataTables` + `.foundation` adapter — adapter must load after base).
- Last: `jquery_ujs` (depends on jQuery but is widely depended-on by forms and links).

### Migration sequence for Category B (first-party files)

**Per-file steps**:

1. **Audit the file's dependents**:
   ```bash
   grep -rn "functionName\|window.functionName" app/assets/javascripts app/views
   ```
   Understand what calls into this file; prioritize files with **zero inbound references** first.

2. **Decide on the integration pattern**:
   - **If the file defines functions called only by other JS files** (not views or AJAX responses): convert to ES6 module, use named `export`, import where needed.
   - **If the file defines functions called by inline event handlers or `.js.erb` AJAX responses**: keep `window.functionName` assignments (those contexts are global-scope), but convert the file itself to a module and explicitly attach: `window.flashHighlight = flashHighlight` at the end.

3. **Move the file** from `app/assets/javascripts/` to `app/javascript/` (or `app/javascript/legacy/` if keeping a visual distinction).

4. **Convert to ES6 module syntax**:
   - Top-level bare `var`/`function` declarations become `export function` or `export const`.
   - Calls to other in-house functions need corresponding `import { X } from "./file"`.
   - Functions exposed for AJAX/global use: `export function X() {}; window.X = X` (or if only used globally, just `window.X = function() {}`).

5. **Add the import** to `app/javascript/application.js`:
   ```js
   import "./legacy/file"  // if file exports for global use
   // or
   import { functionName } from "./legacy/file"  // if used within other modules
   ```

6. **Remove the `//= require` line** from `legacy_application.js`.

7. **Test** the specific page/feature that file drives. For `.js.erb` AJAX responses, trigger the AJAX call and inspect the console for errors.

8. **Commit** — for files with cross-file references, commit the producer and all consumers together so imports/exports agree.

**Recommended order**:
- Utility functions with **zero inbound references** (`block_displayer.js` if truly standalone, etc.).
- Simple page-specific scripts with their own feature area (e.g., `lane_assignment.js` if only used on one page).
- High-reuse utilities last (`flash_highlight.js`, `reorder_rows.js` if called from multiple `.js.erb` files or across multiple pages) — handle these in a single commit with all their call sites.

### Cleanup after full Category A + B migration

Once `legacy_application.js` has no `//= require` lines left:
1. Delete `legacy_application.js`.
2. Remove the `defer: true` flag from all 4 layout files' `javascript_include_tag "legacy_application"` → should become just `javascript_include_tag "legacy_application"` (which will 404, prompting you to remove the line).
3. Remove the now-unused gems from Gemfile (`jquery-rails`, `jquery-datatables-rails`, `select2-rails`, `fancybox2-rails`), run `bundle update`, and verify Sprockets still boots.
4. Optionally: clean up `config/initializers/assets.rb` if all precompile entries were for gem-vendored files now gone.

---

## Implementation Phases

### Phase 0: Blockers Analysis & Audit (8–10 hours)
1. Verify whether `app/assets/javascripts/application.js` is actually loaded (audit browser Network tab on all major page types)
2. If loaded: identify which of the ~20 in-house JS files are live vs. dead code
3. Verify `wicked_pdf` compatibility with Propshaft's asset paths

**Decision gate**: If legacy JS is minimal/dead or refactoring is deemed acceptable, proceed. If large, active codebase, defer migration.

### Phase 1: Sass Compiler Swap (2 hours)
1. Replace `sassc-rails` with `dartsass-rails` in Gemfile
2. `bundle update`
3. Test: `docker-compose run --rm app bundle exec rails assets:precompile`
4. Commit & merge to `propshaft_migration` branch

### Phase 2: Swap Asset Pipeline Gem (2 hours)
1. Remove `sprockets` gem dependency
2. Add `propshaft` gem (latest stable, Rails 8-compatible version)
3. Remove all `config.assets.*` configuration from `config/initializers/assets.rb` and `config/environments/*.rb`
4. Add `config.assets.paths` configuration for load paths (per section 5 above)
5. Test locally: `docker-compose run --rm app bundle exec rails assets:precompile`
6. Commit

### Phase 3: Remove Manifest & Sprockets Configuration (1 hour)
1. Delete `app/assets/config/manifest.js`
2. Clean up any remaining `config.assets.precompile`, `config.assets.compile`, `config.assets.digest`, `config.assets.css_compressor` lines from `config/environments/*.rb`
3. Test: `docker-compose run --rm app bundle exec rails assets:precompile`
4. Commit

### Phase 4: Vendor Asset-Gem Replacements (12–20 hours)
1. For each of the 5 gems (`foundation-rails`, `jquery-rails`, `jquery-datatables-rails`, `select2-rails`, `fancybox2-rails`):
   - Remove from Gemfile
   - Vendor CSS/JS manually or via npm + importmap pins
   - Update view code to remove any Sprockets-specific `require` directives
   - Test: verify styling/functionality on affected pages
2. Test full application locally: `docker-compose up`, navigate major flows (registrants, attending, payments, reports), confirm no visual regressions or JS errors
3. Commit one gem per commit for review clarity

### Phase 5: Legacy JS Refactoring (10–20 hours)
1. Delete dead code from `app/assets/javascripts/`
2. Vendor live, low-priority JS to `app/javascript/vendor/`
3. For high-priority JS: refactor to Stimulus controllers or modern ES6 modules (may span multiple PRs)
4. Test thoroughly
5. Commit per component for review

### Phase 6: PDF & wicked_pdf Verification (2–3 hours)
1. Generate test PDF from a page with images/styling
2. Verify CSS/image inclusion in PDF
3. Adapt `wicked_pdf` configuration if needed
4. Test CI/CD pipeline with PDF generation
5. Commit

### Phase 7: Docker & CI/CD Integration (2–3 hours)
1. Verify `Dockerfile.production` builds successfully with new asset pipeline
2. Verify asset precompile step completes and outputs to `public/assets`
3. Deploy to staging, verify asset loading, run smoke tests
4. Deploy to production if all tests pass
5. Monitor logs for any asset resolution errors

---

## Testing Strategy

**Unit tests**:
- Run existing test suite: `docker-compose run --rm app bundle exec rspec spec/` — should pass without modification (asset pipeline is opaque to app code)

**Integration tests**:
- Manual browser testing on major user flows (registration, event selection, payments, admin reporting)
- Asset precompile locally and test with `RAILS_ENV=production` environment settings
- Verify dynamic stylesheets (`stylesheet_link_tag @config.style_name`) still resolve correctly in all 4 theme variants
- Verify PDF generation includes styles/images correctly

**CI/CD**:
- Verify Docker build (`Dockerfile.production` assets:precompile step) succeeds
- Verify staging deployment loads assets without 404s
- Run CircleCI full test suite

**Rollback plan**:
- Revert to latest Sprockets commit on main branch if critical issues arise
- Propshaft and Sprockets can coexist (importmap-rails detects both), so rollback is reversible without data migration

---

## Estimated Total Effort

| Phase | Effort | Risk |
|-------|--------|------|
| 0. Blockers Audit | 8–10h | Low |
| 1. Sass Compiler | 2h | Low |
| 2. Asset Pipeline Gem | 2h | Low |
| 3. Manifest Removal | 1h | Low |
| 4. Asset Gems Replacement | 12–20h | Medium |
| 5. Legacy JS Refactoring | 10–20h | High |
| 6. PDF Verification | 2–3h | Low |
| 7. Docker/CI Integration | 2–3h | Low |
| **Total** | **39–59 hours** | — |

**Team estimate**: 5–7 working days for an experienced developer; 1–2 weeks for a team unfamiliar with the codebase and Propshaft. Could be parallelized (e.g., Sass compiler + asset-gem vendoring in parallel).

---

## Success Criteria

After migration:
1. ✅ All existing tests pass without modification
2. ✅ `docker-compose run --rm app bundle exec rails assets:precompile` completes without errors
3. ✅ CSS theme variants (`base_blue_pink`, `base_green_blue`, etc.) all load correctly via `stylesheet_link_tag @config.style_name`
4. ✅ Stimulus controllers auto-load without `config.assets.precompile` configuration
5. ✅ PDF generation includes stylesheets and images correctly
6. ✅ No asset 404s on staging or production
7. ✅ No visual regressions on any major user flow
8. ✅ Asset fingerprinting works; browser cache-busting on deploy
9. ✅ `config/initializers/assets.rb` is empty or removed (no asset pipeline configuration needed)

---

## Future Optimizations (Post-Migration)

1. **JavaScript module bundling**: Propshaft can work with esbuild or importmap-rails' bundler to optimize JS module serving (smaller file sizes, fewer HTTP requests)
2. **Sass modernization**: Refactor `@import` to `@use` / `@forward` for Dart Sass strict mode (avoids deprecation warnings)
3. **Upgrade asset gems to npm**: Replace Foundation, DataTables, Select2 gem-bundled versions with npm equivalents for better versioning control and smaller bundle sizes
4. **Image optimization**: Propshaft integrates with image_processing gem for automatic responsive image generation (modern alternative to manually pre-sized images)

---

## References

- [Rails Propshaft Documentation](https://github.com/rails/propshaft)
- [importmap-rails + Propshaft Integration](https://github.com/rails/importmap-rails#propshaft-integration)
- [Sprockets to Propshaft Migration (DHH talk)](https://www.youtube.com/watch?v=OKcNqj3k7gQ)
- [Dartsass-rails](https://github.com/rails/dartsass-rails)
