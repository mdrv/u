<script lang='ts'>
	import type { TreeNode } from '$lib/types.js'

	let { tree, activePath = null, showOnlyAnnotated = false, onSelect }: {
		tree: TreeNode[]
		activePath?: string | null
		showOnlyAnnotated?: boolean
		onSelect?: (e: { detail: { path: string } }) => void
	} = $props()

	function handleNodeClick(node: TreeNode) {
		if (node.type === 'file') {
			onSelect?.({ detail: { path: node.path } })
		}
	}

	function handleToggle(node: TreeNode) {
		node.expanded = !node.expanded
	}

	let filteredTree = $derived(filterTree(tree, showOnlyAnnotated))

	function filterTree(nodes: TreeNode[], onlyAnnotated: boolean): TreeNode[] {
		if (!onlyAnnotated) return nodes

		return nodes
			.map((node) => {
				if (node.type === 'file') {
					return node.isAnnotated || node.path.includes('README.md')
						? node
						: null
				} else if (node.children) {
					const filteredChildren = filterTree(node.children, onlyAnnotated)
					if (filteredChildren.length > 0) {
						return { ...node, children: filteredChildren }
					}
					return null
				}
				return null
			})
			.filter((node): node is TreeNode => node !== null)
	}

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

	function getCategory(category: string): string {
		if (category.includes('nvim')) return 'nvim'
		if (category.includes('nushell')) return 'nushell'
		if (
			category.includes('kitty') || category.includes('foot')
			|| category.includes('zellij')
		) return 'terminal'
		if (category.includes('hypr')) return 'compositor'
		if (
			category.includes('waybar') || category.includes('dunst')
			|| category.includes('tofi') || category.includes('yazi')
		) return 'desktop'
		if (
			category.includes('home') || category.includes('etc')
			|| category.includes('fastfetch')
		) return 'system'
		if (category.includes('otd')) return 'theme'
		if (category.includes('quickshell')) return 'shell'
		return 'misc'
	}
</script>

<nav class='file-tree'>
	<div class='tree-header'>
		<h2>Configs</h2>
		{#if showOnlyAnnotated}
			<span class='filter-badge'>Annotated only</span>
		{/if}
	</div>

	<ul class='tree-list'>
		{#each filteredTree as node (node.path)}
			{@const category = getCategory(node.path)}
			{@const color = getCategoryColor(category)}
			<li
				class='tree-item'
				class:active={activePath === node.path}
				class:annotated={node.isAnnotated}
			>
				{#if node.type === 'directory'}
					<div class='tree-node directory'>
						<button
							class='toggle-button'
							aria-label='Toggle {node.name}'
							onclick={(e) => {
								e.stopPropagation()
								handleToggle(node)
							}}
						>
							{#if node.expanded}
								▼
							{:else}
								▶
							{/if}
						</button>
						<span class='node-name'>{node.name}</span>
					</div>
					{#if node.expanded && node.children}
						<ul class='tree-sublist'>
							{#each node.children as childNode (childNode.path)}
								<svelte:self
									tree={[childNode]}
									{activePath}
									{showOnlyAnnotated}
								/>
							{/each}
						</ul>
					{/if}
				{:else}
					<div
						class='tree-node file'
						onclick={() => handleNodeClick(node)}
						role='button'
						tabindex='0'
						onkeydown={(e) => e.key === 'Enter' && handleNodeClick(node)}
					>
						<span class='file-icon'>📄</span>
						<span class='node-name'>{node.name}</span>
						{#if node.isAnnotated}
							<span class='annotation-indicator' style='background: {color}'
							>①</span>
						{/if}
					</div>
				{/if}
			</li>
		{/each}
	</ul>
</nav>

<style>
	.file-tree {
	  height: 100%;
	  display: flex;
	  flex-direction: column;
	  background: #0d1117;
	  border-right: 1px solid #30363d;
	}

	.tree-header {
	  display: flex;
	  align-items: center;
	  justify-content: space-between;
	  padding: 16px;
	  border-bottom: 1px solid #30363d;
	}

	.tree-header h2 {
	  margin: 0;
	  color: #c9d1d9;
	  font-size: 14px;
	  font-weight: 600;
	}

	.filter-badge {
	  padding: 2px 8px;
	  background: #238636;
	  color: white;
	  border-radius: 9999px;
	  font-size: 10px;
	  font-weight: 600;
	}

	.tree-list {
	  flex: 1;
	  list-style: none;
	  padding: 8px 0;
	  margin: 0;
	  overflow-y: auto;
	}

	.tree-sublist {
	  list-style: none;
	  padding-left: 16px;
	  margin: 4px 0;
	}

	.tree-item {
	  margin: 0;
	}

	.tree-node {
	  display: flex;
	  align-items: center;
	  gap: 8px;
	  padding: 6px 16px;
	  cursor: pointer;
	  transition: background 0.15s ease;
	}

	.tree-node:hover {
	  background: #21262d;
	}

	.tree-node.active {
	  background: #1f6feb;
	}

	.toggle-button {
	  width: 20px;
	  height: 20px;
	  padding: 0;
	  background: none;
	  border: none;
	  color: #8b949e;
	  font-size: 10px;
	  cursor: pointer;
	  display: flex;
	  align-items: center;
	  justify-content: center;
	}

	.toggle-button:hover {
	  color: #c9d1d9;
	}

	.file-icon {
	  font-size: 12px;
	}

	.node-name {
	  flex: 1;
	  color: #c9d1d9;
	  font-size: 13px;
	  white-space: nowrap;
	  overflow: hidden;
	  text-overflow: ellipsis;
	}

	.tree-node.directory .node-name {
	  font-weight: 500;
	}

	.tree-node.active .node-name {
	  color: white;
	}

	.annotation-indicator {
	  display: flex;
	  align-items: center;
	  justify-content: center;
	  width: 16px;
	  height: 16px;
	  border-radius: 9999px;
	  font-size: 9px;
	  font-weight: 600;
	  color: white;
	}

	.tree-item.annotated .annotation-indicator {
	  opacity: 1;
	}
</style>
