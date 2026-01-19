## Context

The `/web` SvelteKit project needs to be deployed to GitHub Pages for public access of the dotfiles documentation site. The current implementation has multiple issues:

- GitHub Actions workflow targets non-existent branch
- Build commands are outdated for SvelteKit 2.x
- Sidebar navigation doesn't function correctly
- TypeScript errors prevent clean builds

## Goals / Non-Goals

**Goals:**

- Successfully deploy SvelteKit static site to GitHub Pages
- Fix all TypeScript errors
- Fix sidebar category navigation to work as expected
- Ensure build and deploy pipeline works correctly
- Maintain existing functionality while fixing bugs

**Non-Goals:**

- Redesigning the UI
- Adding new features beyond fixing existing bugs
- Changing the base path structure unless necessary
- Migrating to a different deployment platform

## Decisions

### 1. GitHub Pages Source Branch

**Decision:** Use `main` branch as the source for GitHub Pages deployment.

**Reasoning:**

- The `gh-pages-site` branch referenced in the workflow doesn't exist
- Repository currently only has `main` and `master` branches
- GitHub Pages can deploy from a subdirectory within the main branch
- This avoids maintaining a separate deployment branch

**Alternatives considered:**

1. Create `gh-pages-site` branch and push there
   - Pros: Separates deployment code from development
   - Cons: Requires additional branch maintenance, extra complexity
2. Use `gh-pages` branch with built output
   - Pros: Standard pattern for GitHub Pages
   - Cons: Requires automated branch management, adds complexity

**Selected approach:** Use `main` branch with workflow deploying `web/build` directory directly.

### 2. Build Command for SvelteKit 2.x

**Decision:** Use `vite build` directly instead of `svelte-kit build`.

**Reasoning:**

- SvelteKit 2.x removed the `svelte-kit build` CLI command
- Vite handles the build process with the SvelteKit plugin
- This is the official recommended approach for SvelteKit 2.x
- Maintains compatibility with the SvelteKit adapter-static

**Alternatives considered:**

1. Downgrade to SvelteKit 1.x
   - Pros: `svelte-kit build` would work
   - Cons: Loses benefits of v2.x, security vulnerabilities
2. Use custom build script with adapter
   - Pros: More control
   - Cons: Unnecessary complexity, doesn't solve root issue

**Selected approach:** Update to `vite build` in package.json scripts.

### 3. Sidebar Category Navigation

**Decision:** Category buttons on homepage should navigate to `/category/[category]` pages using `goto()`.

**Reasoning:**

- Current implementation only updates local state without user-visible effect
- Category pages already exist and are functional
- Users expect clicking a category to navigate to that category
- Follows existing patterns used elsewhere in the app

**Alternatives considered:**

1. Keep local state and filter content on homepage
   - Pros: Single-page experience, no navigation needed
   - Cons: Duplicates logic from category pages, more complex state management
2. Use HTML links instead of programmatic navigation
   - Pros: Simpler, works without JavaScript
   - Cons: SvelteKit prefers `goto()` for navigation, less control

**Selected approach:** Use `goto()` with `resolve()` to navigate to category pages, matching existing patterns in the codebase.

### 4. Base Path Configuration

**Decision:** Keep base path as `/u` and configure GitHub Pages accordingly.

**Reasoning:**

- Base path `/u` suggests the repository name is `u`
- This is a valid and common pattern for GitHub Pages
- Changing base path would require updating all asset references
- The build output already uses `/u` in generated HTML

**Alternatives considered:**

1. Remove base path and use root deployment
   - Pros: Simpler URLs
   - Cons: Would require repository rename or changing all paths
2. Use subdomain instead of subdirectory
   - Pros: Cleaner URLs
   - Cons: Requires DNS configuration, not applicable to GitHub Pages default

**Selected approach:** Keep `/u` base path and ensure GitHub Pages is configured for subdirectory deployment.

## Risks / Trade-offs

### Risk: GitHub Pages Configuration Complexity

**Risk:** GitHub Pages may require specific configuration for subdirectory deployment from a source branch.

**Mitigation:**

- Document the required GitHub Pages settings
- Provide clear instructions for repository configuration
- Test deployment in a test environment if possible

### Trade-off: Navigation vs. State Management

**Trade-off:** Changing sidebar from local state to navigation removes the possibility of filtering content on the homepage.

**Rationale:**

- Category pages already provide filtered views
- Simpler implementation reduces code complexity
- Consistent with user expectations (buttons should navigate)

### Risk: Build Output Path Mismatch

**Risk:** The workflow uploads `./web/build` but GitHub Pages may expect a different path.

**Mitigation:**

- Verify build output directory matches adapter configuration
- Test locally with `bun run build` to confirm output location
- Adapter-static is configured to output to `build` directory

## Migration Plan

**Steps:**

1. Update GitHub Actions workflow file
2. Update package.json build scripts
3. Fix sidebar navigation in `+page.svelte`
4. Fix TypeScript errors in test files
5. Configure GitHub Pages settings in GitHub UI
6. Push changes to trigger deployment
7. Verify deployment and test navigation

**Rollback:**

- Revert changes to workflow and package.json if deployment fails
- Category pages will still work even if GitHub Pages issues occur
- Local development unaffected by deployment configuration

## Open Questions

1. **GitHub repository name:** Is the repository name confirmed to be `u`? The base path `/u` suggests this, but should be verified.
2. **GitHub Pages settings:** Does the user want the site deployed to the default GitHub Pages URL or a custom domain?
3. **Workflow permissions:** Are the current permissions in the workflow sufficient, or are additional permissions needed for GitHub Pages deployment?
