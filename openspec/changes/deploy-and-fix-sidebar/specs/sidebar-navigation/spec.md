## ADDED Requirements

### Requirement: Sidebar Category Navigation

The homepage sidebar MUST provide category buttons that navigate to their respective category pages when clicked.

#### Scenario: Category button navigates to category page

- **GIVEN** the user is on the homepage viewing the sidebar
- **WHEN** clicking on a category button in the category list
- **THEN** the browser should navigate to `/category/[category]` page for the selected category
- **AND** the category page should display files belonging to that category

#### Scenario: All Files button navigates to homepage

- **GIVEN** the user is on the homepage viewing the sidebar
- **WHEN** clicking on the "All Files" button
- **THEN** the user should remain on the homepage with no category filter applied
- **AND** the "All Files" button should be visually marked as active

#### Scenario: Active category button is visually indicated

- **GIVEN** a category button was clicked and navigation occurred
- **WHEN** the new page loads
- **THEN** the corresponding category button in the homepage sidebar should have the `active` class applied
- **AND** other category buttons should not have the `active` class

### Requirement: File Tree Navigation

The file tree component MUST allow navigation to individual file pages when a file node is clicked.

#### Scenario: File click navigates to file page

- **GIVEN** the user is viewing the file tree
- **WHEN** clicking on a file node
- **THEN** the browser should navigate to `/file/[...path]` for that file
- **AND** the file page should display the file content with syntax highlighting

#### Scenario: Directory click expands/collapses

- **GIVEN** the user is viewing the file tree
- **WHEN** clicking on a directory toggle button
- **THEN** the directory should expand to show children if collapsed
- **OR** the directory should collapse to hide children if expanded
