# Claude Code Instructions

## Critical: Running Commands

**ALL ruby/bundler/rails commands must be run inside Docker.**

Use:
```
docker-compose run --rm web <command>
```

Examples:
- `docker-compose run --rm web bundle install`
- `docker-compose run --rm web rails assets:precompile`
- `docker-compose run --rm web bundle exec rspec`

NEVER run `bundle`, `rails`, `gem`, or `rspec` directly in the shell outside Docker.

Do not install packages/tools on the host machine (no `pip install`, `npm install -g`, `brew install`, etc.) for one-off checks — use a Docker container (`docker-compose run --rm app <command>`) instead, even for quick scripting/validation tasks like checking YAML syntax.

## Translation Workflow (ECS)

Translations are managed via Tolk. Source of truth is YAML files in `config/locales/`. The Tolk DB is populated from those files on every ECS deploy via the `sync_translations` CircleCI job.

**To update translations:**
1. Edit translations in the Tolk web UI on staging (`/tolk`)
2. Download all translations as a ZIP via `/tolk/dump_all`
3. Extract and replace files in `config/locales/`
4. Commit and open a PR for review
5. On merge+deploy, `import_translations_from_yml` runs automatically as an ECS one-off task

Do NOT use `cap stage translation:download` — it relies on SSH into EC2 which no longer applies.

## Git Commits

**NEVER use `git add -A` or `git add .`** — this adds every untracked file and causes massive, unrelated commits. Always add files by name:
```bash
git add spec/views/registrants/build/add_contact_details.html.erb_spec.rb spec/spec_helper.rb
```

## Current Branch
See `.claude/memory/MEMORY.md` for current work context.
