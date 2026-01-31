import { getFileByPath } from '$lib/utils/scanRepo.js'
import { error } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ params, parent }) => {
	console.log('Loading file, params.path:', params.path)

	if (!params.path) {
		error(404, 'No file path specified')
	}

	const parentData = await parent()
	const filePath = decodeURIComponent(params.path)

	console.log('Decoded file path:', filePath)

	const repoData = parentData.repoData
	const file = getFileByPath(filePath, repoData)

	if (!file) {
		console.error('File not found:', filePath)
		console.error('Available files:', repoData.files.map(f => f.path))
		error(404, `File not found: ${filePath}`)
	}

	return {
		file,
	}
}
