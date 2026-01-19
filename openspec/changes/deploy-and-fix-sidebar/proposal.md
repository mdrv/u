# Change: Deploy to GitHub Pages and Fix Sidebar Navigation

## Why

The `/web` project needs to be deployed to GitHub Pages for public access, and there are several critical issues preventing a successful deployment:

1. The GitHub Actions workflow targets a non-existent branch (`gh-pages-site`) instead of `main`
2. The build script uses outdated SvelteKit CLI commands that no longer work in v2.x
3. The sidebar category buttons on the homepage don't navigate anywhere - they only update local state without user-visible effect
4. TypeScript errors in test files prevent successful type checking
5. The base path configuration (`/u`) needs verification for proper GitHub Pages routing

## What Changes

- **BREAKING**: Update GitHub workflow to trigger on `main` branch instead of `gh-pages-site`
- Fix build script to use `vite build` instead of deprecated `svelte-kit build`
- Fix sidebar category navigation on homepage to navigate to `/category/[category]` pages instead of just updating local state
- Fix TypeScript errors in test files (implicit any types, deprecated stub methods)
- Verify and configure base path for GitHub Pages deployment
- Add proper null safety checks where TypeScript warnings exist
- Update package.json scripts to ensure compatibility with SvelteKit 2.x

## Impact

- **Affected specs**: New specs needed for `github-pages-deployment` and `sidebar-navigation`
- **Affected code**:
  - `.github/workflows/deploy.yml`
  - `web/package.json`
  - `web/src/routes/+page.svelte`
  - `web/src/lib/components/CodeViewer.test.js`
  - `web/svelte.config.js` (base path may need adjustment)
- **User impact**:
  - Site will be deployed to GitHub Pages at `https://<username>.github.io/u/`
  - Sidebar category buttons will now navigate to category pages
  - All TypeScript errors will be resolved
- **Workflow impact**:
  - GitHub Actions will trigger on pushes to `main` branch
  - Build and deploy will work correctly with SvelteKit 2.x
