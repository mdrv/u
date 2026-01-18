<script lang='ts'>
	import FileTree from '$lib/components/FileTree.svelte'

	let { data } = $props()

	let showOnlyAnnotated = $state(false)
	let selectedCategory = $state<string | null>(null)

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

<div class='home-page'>
	<header class='header'>
		<div class='header-content'>
			<h1 class='title'>μ <span class='subtitle'>Dotfiles</span></h1>
			<p class='description'>
				Interactive exploration of Arch Linux configuration with annotated
				explanations
			</p>
		</div>
		<div class='header-stats'>
			<div class='stat'>
				<span class='stat-value'>{data.repoData.files.length}</span>
				<span class='stat-label'>Files</span>
			</div>
			<div class='stat'>
				<span class='stat-value'>{data.repoData.annotatedFiles.length}</span>
				<span class='stat-label'>Annotated</span>
			</div>
			<div class='stat'>
				<span class='stat-value'>{data.repoData.categories.length}</span>
				<span class='stat-label'>Categories</span>
			</div>
		</div>
	</header>

	<main class='main'>
		<aside class='sidebar'>
			<div class='sidebar-header'>
				<h3>Categories</h3>
			</div>
			<div class='category-list'>
				<button
					class='category-btn'
					class:active={selectedCategory === null}
					onclick={() => (selectedCategory = null)}
				>
					All Files
				</button>
				{#each data.repoData.categories as category}
					<button
						class='category-btn'
						class:active={selectedCategory === category.category}
						onclick={() => (selectedCategory = category.category)}
					>
						<span class='category-name'>{category.category}</span>
						<span class='category-count'>{category.files.length}</span>
					</button>
				{/each}
			</div>

			<div class='sidebar-header'>
				<h3>File Tree</h3>
				<label class='toggle-label'>
					<input type='checkbox' bind:checked={showOnlyAnnotated} />
					<span>Annotated only</span>
				</label>
			</div>
			<div class='file-tree-container'>
				<FileTree
					tree={data.repoData.fileTree}
					showOnlyAnnotated={showOnlyAnnotated}
					onSelect={(e) => {
						const path = e.detail.path
						window.location.href = `/file/${encodeURIComponent(path)}`
					}}
				/>
			</div>
		</aside>

		<div class='content'>
			<div class='welcome-card'>
				<h2>Welcome to μ Dotfiles</h2>
				<p>
					This interactive site showcases my Arch Linux configuration files.
					Browse the file tree on the left to explore different configs.
				</p>

				{#if data.repoData.annotatedFiles.length > 0}
					<div class='highlighted-files'>
						<h3>Annotated Files</h3>
						<div class='file-grid'>
							{#each data.repoData.annotatedFiles.slice(0, 6) as file}
								<a
									href='/file/{encodeURIComponent(file.path)}'
									class='file-card'
									style='border-color: {getCategoryColor(file.category)}'
								>
									<div class='file-card-icon'>📄</div>
									<div class='file-card-info'>
										<div class='file-card-name'>{file.name}</div>
										<div class='file-card-path'>{file.path}</div>
										<div class='file-card-annotations'>
											{file.annotations.length} annotations
										</div>
									</div>
								</a>
							{/each}
						</div>
					</div>
				{/if}

				<div class='categories-overview'>
					<h3>Categories</h3>
					<div class='category-grid'>
						{#each data.repoData.categories as category}
							<a
								href='/category/{category.category}'
								class='category-card'
								style='border-color: {getCategoryColor(category.category)}'
							>
								<div class='category-card-name'>{category.category}</div>
								<div class='category-card-count'>
									{category.files.length} files
								</div>
								<div class='category-card-annotated'>
									{category.files.filter((f) => f.isAnnotated).length} annotated
								</div>
							</a>
						{/each}
					</div>
				</div>
			</div>
		</div>
	</main>
</div>

<style>
	.home-page {
	  flex: 1;
	  display: flex;
	  flex-direction: column;
	}

	.header {
	  background: linear-gradient(135deg, #0d1117 0%, #161b22 100%);
	  border-bottom: 1px solid #30363d;
	  padding: 32px 24px;
	}

	.header-content {
	  max-width: 1400px;
	  margin: 0 auto;
	}

	.title {
	  margin: 0;
	  font-size: 48px;
	  font-weight: 700;
	  color: #c9d1d9;
	}

	.subtitle {
	  color: #8b949e;
	  font-weight: 400;
	}

	.description {
	  margin: 8px 0 0;
	  color: #8b949e;
	  font-size: 16px;
	}

	.header-stats {
	  display: flex;
	  gap: 24px;
	  margin-top: 24px;
	}

	.stat {
	  display: flex;
	  flex-direction: column;
	  gap: 4px;
	}

	.stat-value {
	  font-size: 28px;
	  font-weight: 700;
	  color: #c9d1d9;
	}

	.stat-label {
	  font-size: 12px;
	  color: #8b949e;
	  text-transform: uppercase;
	  letter-spacing: 0.5px;
	}

	.main {
	  display: flex;
	  flex: 1;
	  max-width: 1400px;
	  margin: 0 auto;
	  width: 100%;
	}

	.sidebar {
	  width: 320px;
	  flex-shrink: 0;
	  background: #0d1117;
	  border-right: 1px solid #30363d;
	  display: flex;
	  flex-direction: column;
	  overflow: hidden;
	}

	.sidebar-header {
	  display: flex;
	  align-items: center;
	  justify-content: space-between;
	  padding: 16px;
	  border-bottom: 1px solid #30363d;
	}

	.sidebar-header h3 {
	  margin: 0;
	  font-size: 14px;
	  font-weight: 600;
	  color: #c9d1d9;
	}

	.toggle-label {
	  display: flex;
	  align-items: center;
	  gap: 8px;
	  font-size: 12px;
	  color: #8b949e;
	  cursor: pointer;
	}

	.category-list {
	  padding: 8px;
	  border-bottom: 1px solid #30363d;
	}

	.category-btn {
	  width: 100%;
	  display: flex;
	  align-items: center;
	  justify-content: space-between;
	  padding: 8px 12px;
	  background: transparent;
	  border: 1px solid transparent;
	  border-radius: 6px;
	  color: #c9d1d9;
	  font-size: 13px;
	  text-align: left;
	  cursor: pointer;
	  transition: all 0.15s ease;
	}

	.category-btn:hover {
	  background: #21262d;
	}

	.category-btn.active {
	  background: #1f6feb;
	  border-color: #1f6feb;
	  color: white;
	}

	.category-count {
	  padding: 2px 8px;
	  background: #21262d;
	  border-radius: 9999px;
	  font-size: 11px;
	  font-weight: 600;
	}

	.category-btn.active .category-count {
	  background: rgba(255, 255, 255, 0.2);
	}

	.file-tree-container {
	  flex: 1;
	  overflow: hidden;
	}

	.content {
	  flex: 1;
	  padding: 32px;
	  overflow-y: auto;
	}

	.welcome-card {
	  background: #161b22;
	  border: 1px solid #30363d;
	  border-radius: 8px;
	  padding: 32px;
	}

	.welcome-card h2 {
	  margin: 0 0 16px;
	  color: #c9d1d9;
	  font-size: 24px;
	  font-weight: 600;
	}

	.welcome-card h3 {
	  margin: 24px 0 16px;
	  color: #c9d1d9;
	  font-size: 18px;
	  font-weight: 600;
	}

	.welcome-card p {
	  color: #8b949e;
	  font-size: 14px;
	  line-height: 1.6;
	}

	.highlighted-files {
	  margin-top: 32px;
	}

	.file-grid {
	  display: grid;
	  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
	  gap: 16px;
	}

	.file-card {
	  display: flex;
	  gap: 12px;
	  padding: 16px;
	  background: #0d1117;
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

	.file-card-icon {
	  font-size: 24px;
	}

	.file-card-info {
	  flex: 1;
	  min-width: 0;
	}

	.file-card-name {
	  color: #c9d1d9;
	  font-weight: 600;
	  font-size: 14px;
	  white-space: nowrap;
	  overflow: hidden;
	  text-overflow: ellipsis;
	}

	.file-card-path {
	  color: #8b949e;
	  font-size: 11px;
	  margin-top: 2px;
	}

	.file-card-annotations {
	  color: #22c55e;
	  font-size: 11px;
	  margin-top: 4px;
	}

	.categories-overview {
	  margin-top: 32px;
	}

	.category-grid {
	  display: grid;
	  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
	  gap: 16px;
	}

	.category-card {
	  padding: 20px;
	  background: #0d1117;
	  border: 2px solid #30363d;
	  border-radius: 8px;
	  text-decoration: none;
	  transition: all 0.2s ease;
	  display: flex;
	  flex-direction: column;
	  gap: 4px;
	}

	.category-card:hover {
	  border-color: #1f6feb;
	  transform: translateY(-2px);
	  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
	}

	.category-card-name {
	  color: #c9d1d9;
	  font-weight: 600;
	  font-size: 16px;
	  text-transform: capitalize;
	}

	.category-card-count {
	  color: #8b949e;
	  font-size: 12px;
	}

	.category-card-annotated {
	  color: #22c55e;
	  font-size: 11px;
	  font-weight: 500;
	}

	@media (max-width: 768px) {
	  .main {
	    flex-direction: column;
	  }

	  .sidebar {
	    width: 100%;
	    max-height: 400px;
	  }

	  .header {
	    padding: 24px 16px;
	  }

	  .title {
	    font-size: 36px;
	  }

	  .header-stats {
	    flex-wrap: wrap;
	  }

	  .content {
	    padding: 16px;
	  }
	}
</style>
