<script lang='ts'>
	import type { RepoData } from '$lib/utils/scanRepo.js'
	import { setContext } from 'svelte'

	let { data }: { data: { repoData: RepoData } } = $props()

	setContext('repoData', data.repoData)
</script>

<svelte:head>
	<title>μ Dotfiles - Arch Linux Configuration</title>
	<meta
		name='description'
		content='Interactive exploration of Arch Linux dotfiles with annotated configurations'
	/>
	<link rel='icon' href='/favicon.ico' />
</svelte:head>

<div class='app'>
	<slot />
</div>

<style>
	:global(body) {
	  margin: 0;
	  padding: 0;
	  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
	  background: #0d1117;
	  color: #c9d1d9;
	  line-height: 1.6;
	}

	:global(*) {
	  box-sizing: border-box;
	}

	.app {
	  min-height: 100vh;
	  display: flex;
	  flex-direction: column;
	}

	:global(a) {
	  color: #58a6ff;
	  text-decoration: none;
	}

	:global(a:hover) {
	  text-decoration: underline;
	}
</style>
