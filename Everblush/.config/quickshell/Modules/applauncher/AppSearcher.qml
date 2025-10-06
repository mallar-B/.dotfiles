import Quickshell
import QtQuick

Item {
	property var searchText: ""
	property var apps: DesktopEntries.applications.values
	onSearchTextChanged: searchApps(searchText)
	// Exposing the ListModel
	property alias resultsModel: resultsModelInternal

	// Holds search results
	ListModel {
		id: resultsModelInternal
	}
	// Search function
	function searchApps(query) {
		resultsModel.clear()
		// resultsList.currentIndex = 0
		const lowerQuery = query.toLowerCase().trim()

		for (const app of apps){
			const name = (app.name || "").toLowerCase() // "" to avoid calling in undefined
			const genericName = (app.genericName || "").toLowerCase()
			const description = (app.comment || "").toLowerCase()
			const keywords = app.keywords.length ? app.keywords.map(s => s.toLowerCase()) : []

			// Matching.  TODO: fuzzyfind support
			if (name.includes(lowerQuery) || description.includes(lowerQuery) || genericName.includes(lowerQuery)) {
				// Had to store the app(DesktopEntry) in a custom object because
				// the DesktopEntry is getting wrapped by defaul QObject
				// from the ListModel, and then could not access the app.command somehow
				resultsModelInternal.append({
					"app": app,
					"name": name,
					"description": description,
					"icon": app.icon || "application-x-executable",
					"genericName": genericName,
					})
				// print(app.command)
			}
			else if (keywords.length > 0){
				for (const k of keywords){
					if (k.includes(lowerQuery)){
						resultsModel.append(app)
					}
				}
			}
		}
	}
}
