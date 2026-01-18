import { scanRepo } from '$lib/utils/scanRepo.js'
import { resolve } from 'path'

const repoRoot = resolve('..')

export function load() {
	const repoData = scanRepo(repoRoot)

	return {
		repoData,
	}
}
