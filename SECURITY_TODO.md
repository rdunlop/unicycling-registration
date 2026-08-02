# Security Findings & TODOs

## 1. Unauthenticated ActiveStorage Direct Uploads Endpoint

**Severity:** High

**Issue:** 
Rails' built-in `ActiveStorage::DirectUploadsController` (`/rails/active_storage/direct_uploads` route) is **not authenticated by default**. Anyone on the internet, logged in or not, can POST to this endpoint and receive a valid presigned S3 upload URL for your bucket.

**Current State:**
- No authentication guard on the direct uploads endpoint
- The endpoint does not inherit from `ApplicationController` or `ConventionSetup::BaseConventionSetupController`
- No initializer currently exists to add `authenticate_user!` to this controller
- Devise is configured globally but only applies to controllers that inherit from `ApplicationController`

**Impact:**
- Any attacker can mint valid S3 presigned URLs without authorization
- They can upload arbitrary files to your S3 bucket (using curl/scripting)
- Combined with open CORS (`AllowedOrigins: "*"`), they could also use a browser-based attack to complete the upload

**Fix - Option 1 (Recommended, 1-line fix):**
Add authentication via an initializer:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.to_prepare do
  ActiveStorage::DirectUploadsController.class_eval do
    before_action :authenticate_user!
    # Optional: add rate limiting
    # rate_limit to: 20, within: 20.minutes, by: -> { current_user.id }
  end
end
```

This reuses Devise's `authenticate_user!` which is globally available, requires no route changes, and gates the endpoint to logged-in users only.

**Fix - Option 2 (More explicit):**
Create a custom controller subclass:

```ruby
# app/controllers/direct_uploads_controller.rb
class DirectUploadsController < ActiveStorage::DirectUploadsController
  before_action :authenticate_user!
end
```

Then add to `config/routes.rb`:
```ruby
resource :direct_uploads, only: :create, as: :rails_direct_uploads, controller: "direct_uploads"
```

**Recommendation:** Option 1. It's minimal, requires no route surgery, and fits the app's existing patterns.

---

## 2. S3 CORS Policy - Hardcoded Domain List & Maintenance Burden

**Severity:** Low-Medium (attack requires either: the auth fix above, or direct AWS access)

**Issue:**
The S3 bucket (`registrationtest` in AWS Console) has a hardcoded CORS policy that explicitly lists allowed origins:

```json
{
  "AllowedOrigins": [
    "https://registrationtest.regtest.unicycling-software.com"
  ],
  "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
  "AllowedHeaders": ["*"],
  "ExposeHeaders": ["ETag"],
  "MaxAgeSeconds": 3000
}
```

**Problems:**
1. **Manual maintenance:** S3 CORS does not support wildcard patterns like `*.regtest.unicycling-software.com`. Every new environment/domain requires manual AWS Console updates.
2. **Blast radius if CORS = "*":** Setting `AllowedOrigins` to `["*"]` removes a layer of defense-in-depth. It doesn't create a new vulnerability on its own (the real gate is authentication on the `/rails/active_storage/direct_uploads` endpoint), but it widens the blast radius of any future authentication bypass.

**Current Threat Model:**
- Narrow CORS list: Attacker can mint a presigned URL (if unauthenticated endpoint not fixed), but can only complete a browser-based S3 PUT if they can serve their payload from one of the whitelisted origins. Requires script/curl to bypass.
- `AllowedOrigins: "*"`: Same attacker can complete a browser-based attack silently from any website (no scripting needed).

**Solution Options:**

### Option A: Automate CORS via Terraform (medium-term, easier)
Move S3 CORS policy to IaC so domain changes are tracked in version control:

```hcl
# terraform/s3.tf
variable "allowed_origins" {
  type = list(string)
  default = [
    "https://registrationtest.regtest.unicycling-software.com",
    # Add new domains here as environments are created
  ]
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
```

Still requires manual variable updates, but changes are version-controlled and deployed consistently.

### Option B: Proxy S3 Requests (longer-term, eliminates CORS issue)
Route all ActiveStorage uploads through the Rails app instead of direct browser-to-S3:
- Configure Rails to **not** use direct uploads (disable `config.active_storage.direct_upload`)
- Build a new controller endpoint in `convention_setup` namespace that accepts file uploads and creates blobs server-side
- Browser makes request to Rails app (same-origin, no CORS), Rails handles S3 communication internally
- Eliminates per-domain CORS maintenance entirely
- More complex infrastructure and requires JS changes (Trix/ActionText currently expect direct uploads)

**Affected Rich Text Fields:**
- `Page#body` (convention setup)
- `EventConfiguration#offline_payment_description` (convention setup)
- Dynamic translation rich-text fields (admin)

All are admin-only, low volume, so Option B is feasible if the architectural simplification is worth it. Option A is quicker to implement.

**Recommendation:** Implement the **authentication fix (Section 1, Option 1) first**. Then choose between Option A (Terraform CORS, quicker) or Option B (proxy controller, eliminates CORS entirely but more work). Option A is lower-risk starting point.

---

## 3. Notes on Direct Upload Implementation

**Current State:**
- `@rails/activestorage` is pinned in `config/importmap.rb` but only loaded indirectly via `@rails/actiontext`
- `app/javascript/application.js` does not explicitly import ActiveStorage; only Trix and ActionText are imported
- Trix editor (inside ActionText) auto-handles image attachment via direct upload when an image is pasted/dropped
- No explicit `fetch()` calls for uploads anywhere in `app/javascript` (all existing Stimulus controllers predate this pattern)
- JavaScript framework: Stimulus (for future proxy controller implementation, will need a new Stimulus controller)

**If implementing Option B (proxy controller):**
- Will need a new Stimulus controller for the fetch-based file upload
- Must read CSRF token from meta tag and include in `X-CSRF-Token` header
- Controller must be in `convention_setup` namespace, authenticated via `authenticate_user!` + Pundit authorization
- This would be a pattern first in this app (no existing precedent for Stimulus + fetch/XHR in the JS layer)

---

## File Upload Methods in This App (Context)

This app uses two separate upload stacks:

1. **ActiveStorage** (S3 direct):
   - Backs ActionText rich-text bodies (`Page#body`, `EventConfiguration#offline_payment_description`, translation wysiwyg fields)
   - Goes via `/rails/active_storage/direct_uploads` → S3 presigned URL (browser-to-S3)
   - Affected by both CORS and the unauthenticated endpoint issue

2. **CarrierWave** (proxied through Rails):
   - Used by `Song`, `Report`, `PageImage`, `UploadedFile`, `CompetitionResult`, `Export`, `Registrant`, `EventConfiguration`
   - All file uploads go through Rails server (no direct S3, no CORS issue)
   - Not affected by this security review

---

## Action Items

- [ ] **Phase 1 (immediate):** Add authentication to `ActiveStorage::DirectUploadsController` via `config/initializers/active_storage.rb` (see Option 1 above)
- [ ] **Phase 2 (coordinate with DevOps/Infrastructure):** Decide between Option A (Terraform CORS automation) vs Option B (proxy controller). Document decision.
- [ ] If Option A: Add `aws_s3_bucket_cors_configuration` resource to Terraform, deploy.
- [ ] If Option B: Design and implement proxy controller in `convention_setup` namespace, update Trix/ActionText configuration to disable direct uploads, build Stimulus controller for fetch-based uploads.

---

## References

- [ActiveStorage Direct Uploads Security Issue (rails/rails#34961)](https://github.com/rails/rails/issues/34961)
- [Secure Active Storage Direct Uploads in Rails (Flixtechs, Medium)](https://flixtechs.medium.com/secure-active-storage-direct-uploads-in-rails-a367434b98a1)
- [Protecting ActiveStorage Uploads - Blogging On Rails](https://onrails.blog/2020/12/10/protecting-activestorage-uploads/)
- Memory note: [[actiontext_s3_cors_issue]]
