<script lang='ts'>
	let { data }: { data: any } = $props()

	let showOnlyAnnotated = $state(false)
	let searchTerm = $state('')
	let sortBy = $state<'name' | 'path' | 'annotations'>('name')

	let filteredFiles = $derived.by(() =>
		data.files
			.filter((f) => {
				if (showOnlyAnnotated && !f.isAnnotated) return false
				if (
					searchTerm && !f.name.toLowerCase().includes(searchTerm.toLowerCase())
					&& !f.path.toLowerCase().includes(searchTerm.toLowerCase())
				) {
					return false
				}
				return true
			})
			.sort((a, b) => {
				if (sortBy === 'name') return a.name.localeCompare(b.name)
				if (sortBy === 'path') return a.path.localeCompare(b.path)
				if (sortBy === 'annotations') {
					return b.annotations.length - a.annotations.length
				}
				return 0
			})
	)

	function getCategoryColor(category: string): string {
		const colors: Record<string, string> = {
			nvim: '#22c55e',
			nushell: '#a855f7',
			terminal: '#3b82f6',
			compositor: '#f59e0b',
			desktop: '#ec4899',
			system: '#6366f1',
			theme: '#14b8a6',
			shell: '#f97316',
			misc: '#64748b',
		}
		return colors[category] || '#64748b'
	}
</script>

<div class='category-page'>
	<header
		class='page-header'
		style='border-color: {getCategoryColor(data.category)}'
	>
		<div class='header-content'>
			<a href='/' class='back-link'>← Back to all files</a>
			<h1 class='category-title'>{data.category}</h1>
			<p class='category-description'>
				{filteredFiles.length} {filteredFiles.length === 1 ? 'file' : 'files'}
				in this category
			</p>
		</div>
	</header>

	<main class='main'>
		<aside class='sidebar'>
			<div class='sidebar-section'>
				<h3>Filter</h3>
				<label class='toggle-label'>
					<input type='checkbox' bind:checked={showOnlyAnnotated} />
					<span>Annotated only</span>
				</label>
			</div>

			<div class='sidebar-section'>
				<h3>Search</h3>
				<input
					type='text'
					bind:value={searchTerm}
					placeholder='Search files...'
					class='search-input'
				/>
			</div>

			<div class='sidebar-section'>
				<h3>Sort by</h3>
				<select bind:value={sortBy} class='sort-select'>
					<option value='name'>Name</option>
					<option value='path'>Path</option>
					<option value='annotations'>Most annotated</option>
				</select>
			</div>

			<div class='sidebar-section'>
				<h3>Stats</h3>
				<div class='stats-grid'>
					<div class='stat-item'>
						<span class='stat-value'>{data.files.length}</span>
						<span class='stat-label'>Total files</span>
					</div>
					<div class='stat-item'>
						<span class='stat-value'>{
							data.files.filter((f) => f.isAnnotated).length
						}</span>
						<span class='stat-label'>Annotated</span>
					</div>
				</div>
			</div>
		</aside>

		<div class='content'>
			<div class='file-list'>
				{#each filteredFiles as file}
					<a
						href='/file/{encodeURIComponent(file.path)}'
						class='file-card'
						style='border-color: {getCategoryColor(data.category)}'
					>
						<div class='file-card-main'>
							<div class='file-icon'>📄</div>
							<div class='file-info'>
								<div class='file-name'>{file.name}</div>
								<div class='file-path'>{file.path}</div>
							</div>
						</div>
						<div class='file-meta'>
							{#if file.isAnnotated}
								<span class='annotation-badge'>
									<span class='annotation-icon'>①</span>
									{file.annotations.length}
								</span>
							{/if}
							<span class='language-badge'>{file.language}</span>
						</div>
					</a>
				{/each}

				{#if filteredFiles.length === 0}
					<div class='empty-state'>
						<div class='empty-icon'>🔍</div>
						<h3>No files found</h3>
						<p>Try adjusting your filters or search terms.</p>
					</div>
				{/if}
			</div>
		</div>
	</main>
</div>

<style>
	.category-page {
	  flex: 1;
	  display: flex;
	  flex-direction: column;
	  overflow: hidden;
	}

	.page-header {
	  background: #161b22;
	  border-bottom: 2px solid #30363d;
	  padding: 24px;
	}

	.header-content {
	  max-width: 1400px;
	  margin: 0 auto;
	}

	.back-link {
	  display: inline-flex;
	  align-items: center;
	  gap: 4px;
	  color: #8b949e;
	  text-decoration: none;
	  font-size: 14px;
	  margin-bottom: 12px;
	}

	.back-link:hover {
	  color: #58a6ff;
	}

	.category-title {
	  margin: 0 0 8px;
	  font-size: 36px;
	  font-weight: 700;
	  color: #c9d1d9;
	  text-transform: capitalize;
	}

	.category-description {
	  margin: 0;
	  color: #8b949e;
	  font-size: 14px;
	}

	.main {
	  display: flex;
	  flex: 1;
	  max-width: 1400px;
	  width: 100%;
	  margin: 0 auto;
	  overflow: hidden;
	}

	.sidebar {
	  width: 280px;
	  flex-shrink: 0;
	  background: #0d1117;
	  border-right: 1px solid #30363d;
	  padding: 20px;
	  display: flex;
	  flex-direction: column;
	  gap: 24px;
	  overflow-y: auto;
	}

	.sidebar-section h3 {
	  margin: 0 0 12px;
	  font-size: 13px;
	  font-weight: 600;
	  color: #8b949e;
	  text-transform: uppercase;
	  letter-spacing: 0.5px;
	}

	.toggle-label {
	  display: flex;
	  align-items: center;
	  gap: 8px;
	  font-size: 14px;
	  color: #c9d1d9;
	  cursor: pointer;
	}

	.search-input {
	  width: 100%;
	  padding: 8px 12px;
	  background: #21262d;
	  border: 1px solid #30363d;
	  border-radius: 6px;
	  color: #c9d1d9;
	  font-size: 14px;
	}

	.search-input:focus {
	  outline: none;
	  border-color: #1f6feb;
	}

	.search-input::placeholder {
	  color: #8b949e;
	}

	.sort-select {
	  width: 100%;
	  padding: 8px 12px;
	  background: #21262d;
	  border: 1px solid #30363d;
	  border-radius: 6px;
	  color: #c9d1d9;
	  font-size: 14px;
	}

	.stats-grid {
	  display: grid;
	  grid-template-columns: 1fr 1fr;
	  gap: 12px;
	}

	.stat-item {
	  display: flex;
	  flex-direction: column;
	  gap: 4px;
	}

	.stat-value {
	  font-size: 20px;
	  font-weight: 700;
	  color: #c9d1d9;
	}

	.stat-label {
	  font-size: 11px;
	  color: #8b949e;
	}

	.content {
	  flex: 1;
	  overflow-y: auto;
	  padding: 24px;
	}

	.file-list {
	  display: grid;
	  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
	  gap: 16px;
	}

	.file-card {
	  display: flex;
	  align-items: center;
	  justify-content: space-between;
	  padding: 16px;
	  background: #161b22;
	  border: 2px solid #30363d;
	  border-radius: 8px;
	  text-decoration: none;
	  transition: all 0.2s ease;
	}

	.file-card:hover {
	  border-color: #1f6feb;
	  transform: translateY(-2px);
	  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
	}

	.file-card-main {
	  display: flex;
	  align-items: center;
	  gap: 12px;
	  flex: 1;
	  min-width: 0;
	}

	.file-icon {
	  font-size: 24px;
	  flex-shrink: 0;
	}

	.file-info {
	  flex: 1;
	  min-width: 0;
	}

	.file-name {
	  color: #c9d1d9;
	  font-weight: 600;
	  font-size: 14px;
	  white-space: nowrap;
	  overflow: hidden;
	  text-overflow: ellipsis;
	}

	.file-path {
	  color: #8b949e;
	  font-size: 12px;
	  margin-top: 2px;
	}

	.file-meta {
	  display: flex;
	  align-items: center;
	  gap: 8px;
	  flex-shrink: 0;
	}

	.annotation-badge {
	  display: inline-flex;
	  align-items: center;
	  gap: 4px;
	  padding: 4px 8px;
	  background: #238636;
	  border-radius: 9999px;
	  color: white;
	  font-size: 11px;
	  font-weight: 600;
	}

	.annotation-icon {
	  font-size: 10px;
	}

	.language-badge {
	  padding: 4px 8px;
	  background: #21262d;
	  border-radius: 9999px;
	  color: #8b949e;
	  font-size: 11px;
	  font-weight: 600;
	}

	.empty-state {
	  display: flex;
	  flex-direction: column;
	  align-items: center;
	  justify-content: center;
	  padding: 64px;
	  text-align: center;
	}

	.empty-icon {
	  font-size: 48px;
	  margin-bottom: 16px;
	}

	.empty-state h3 {
	  margin: 0 0 8px;
	  color: #c9d1d9;
	  font-size: 18px;
	}

	.empty-state p {
	  margin: 0;
	  color: #8b949e;
	  font-size: 14px;
	}

	@media (max-width: 768px) {
	  .main {
	    flex-direction: column;
	  }

	  .sidebar {
	    width: 100%;
	    max-height: 300px;
	  }

	  .file-list {
	    grid-template-columns: 1fr;
	  }

	  .category-title {
	    font-size: 28px;
	  }
	}
</style>
