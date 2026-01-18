<script lang='ts'>
	import { goto } from '$app/navigation'
	import { resolve } from '$app/paths'
	import CodeViewerComponent from '$lib/components/CodeViewer.svelte'
	import FileTree from '$lib/components/FileTree.svelte'

	let { data }: { data: any } = $props()

	let showOnlyAnnotated = $state(false)
	let selectedCategory = $state<string | null>(null)
</script>

<div class='file-page'>
	<header class='page-header'>
		<h1>{data.file.name}</h1>
		<div class='breadcrumb'>
			<a href='../..' class='back-link'>Dotfiles</a>
			<span class='separator'>/</span>
			<a
				href={resolve('/category/[category]', { category: data.file.category })}
			>{data.file.category}</a>
			<span class='separator'>/</span>
			<span>{data.file.name}</span>
		</div>
		<div class='file-meta'>
			{#if data.file.isAnnotated}
				<span class='badge annotated-badge'>
					<span class='badge-icon'>①</span>
					{data.file.annotations.length} annotations
				</span>
			{/if}
			<span class='badge category-badge'>{data.file.category}</span>
			<span class='badge language-badge'>{data.file.language}</span>
		</div>
	</header>

	<main class='main'>
		<aside class='sidebar'>
			<div class='sidebar-header'>
				<h3>File Tree</h3>
			</div>
			<FileTree
				tree={data.repoData.fileTree}
				showOnlyAnnotated={showOnlyAnnotated}
				onSelect={(e) => {
					const path = e.detail.path
					if (path !== data.file.path) {
						goto(resolve('/file/[...path]', { path }))
					}
				}}
			/>
		</aside>

		<div class='content'>
			<CodeViewerComponent file={data.file} />
		</div>
	</main>
</div>

<style>
	.file-page {
	  flex: 1;
	  display: flex;
	  flex-direction: column;
	  overflow: hidden;
	}

	.page-header {
	  background: #161b22;
	  border-bottom: 1px solid #30363d;
	  padding: 20px 24px;
	}

	.page-header h1 {
	  margin: 0 0 8px;
	  font-size: 28px;
	  font-weight: 600;
	  color: #c9d1d9;
	}

	.breadcrumb {
	  display: flex;
	  align-items: center;
	  gap: 8px;
	  font-size: 14px;
	  color: #8b949e;
	  margin-bottom: 12px;
	}

	.breadcrumb a {
	  color: #58a6ff;
	  text-decoration: none;
	}

	.breadcrumb a:hover {
	  text-decoration: underline;
	}

	.separator {
	  color: #484f58;
	}

	.file-meta {
	  display: flex;
	  gap: 8px;
	}

	.badge {
	  display: inline-flex;
	  align-items: center;
	  gap: 4px;
	  padding: 4px 12px;
	  border-radius: 9999px;
	  font-size: 12px;
	  font-weight: 600;
	}

	.annotated-badge {
	  background: #238636;
	  color: white;
	}

	.badge-icon {
	  font-size: 10px;
	}

	.category-badge {
	  background: #1f6feb;
	  color: white;
	}

	.language-badge {
	  background: #6366f1;
	  color: white;
	}

	.main {
	  display: flex;
	  flex: 1;
	  overflow: hidden;
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
	  padding: 16px;
	  border-bottom: 1px solid #30363d;
	}

	.sidebar-header h3 {
	  margin: 0;
	  font-size: 14px;
	  font-weight: 600;
	  color: #c9d1d9;
	}

	.content {
	  flex: 1;
	  overflow: hidden;
	  background: #0d1117;
	}

	@media (max-width: 768px) {
	  .main {
	    flex-direction: column;
	  }

	  .sidebar {
	    width: 100%;
	    max-height: 300px;
	  }

	  .page-header {
	    padding: 16px;
	  }

	  .page-header h1 {
	    font-size: 22px;
	  }
	}
</style>
