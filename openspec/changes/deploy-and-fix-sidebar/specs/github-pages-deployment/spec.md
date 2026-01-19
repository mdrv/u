## ADDED Requirements

### Requirement: GitHub Pages Build Workflow

The system SHALL provide a GitHub Actions workflow that automatically builds and deploys the SvelteKit site to GitHub Pages when code is pushed to the `main` branch.

#### Scenario: Workflow triggers on main branch push

- **GIVEN** the GitHub Actions workflow file is configured
- **WHEN** code is pushed to the `main` branch with changes to `web/**` paths
- **THEN** the workflow should trigger and start the build process

#### Scenario: Build produces static site output

- **GIVEN** Bun is installed and dependencies are available
- **WHEN** the build step runs `vite build` in the `web` directory
- **THEN** static HTML, CSS, and JavaScript files should be generated in `web/build` directory

#### Scenario: Artifact upload for deployment

- **GIVEN** the build completes successfully
- **WHEN** the upload-artifact step runs
- **THEN** the `web/build` directory should be uploaded as a Pages artifact

#### Scenario: Deploy to GitHub Pages

- **GIVEN** the build artifact is available
- **WHEN** the deploy-pages action runs
- **THEN** the artifact should be deployed to GitHub Pages using the configured base path `/u`

### Requirement: SvelteKit 2.x Compatible Build

The build script MUST use Vite build commands compatible with SvelteKit 2.x to generate the static site.

#### Scenario: Build script executes successfully

- **GIVEN** the package.json build script is configured correctly
- **WHEN** running `bun run build` in the web directory
- **THEN** Vite should build the static site without errors using SvelteKit adapter-static

#### Scenario: Build output contains necessary files

- **GIVEN** the build completes
- **WHEN** examining the `build` directory
- **THEN** it should contain `index.html`, `404.html`, and the `_app` directory with assets

### Requirement: Base Path Configuration

The SvelteKit configuration MUST use the correct base path for GitHub Pages deployment with subdirectory routing.

#### Scenario: Assets reference correct base path

- **GIVEN** the base path is configured as `/u` in svelte.config.js
- **WHEN** the site is built
- **THEN** all asset references in HTML should include the `/u` prefix

#### Scenario: Navigation works with base path

- **GIVEN** the site is deployed to GitHub Pages at the base path
- **WHEN** users navigate between pages
- **THEN** URLs should correctly include the `/u` prefix and all navigation should work
