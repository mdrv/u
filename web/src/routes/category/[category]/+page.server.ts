import { getCategoryFiles } from '$lib/utils/scanRepo.js'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ params, parent }) => {
	const parentData = await parent()
	const category = params.category

	const files = getCategoryFiles(category, parentData.data.repoData)

	if (files.length === 0) {
		throw new Error('Category not found')
	}

	return {
		category,
		files,
	}
}
