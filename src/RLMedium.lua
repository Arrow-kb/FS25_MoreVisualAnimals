RLMedium = {}

modDirectory = g_currentModDirectory
modSettingsDirectory = g_currentModSettingsDirectory


local function initialiseFilesRecursively(path)

	local files = Files.new(path).files

	for _, file in pairs(files) do

		if file.filename == "RLMedium.lua" then continue end

		if not file.isDirectory then
			
			source(file.path)
			continue

		end

		initialiseFilesRecursively(file.path)

	end

end


function RLMedium.loadMap()

	if not g_modIsLoaded["FS25_RealisticLivestock"] then

		initialiseFilesRecursively(modDirectory .. "src")

		local xmlFile = XMLFile.loadIfExists("visualAnimalsCap", modSettingsDirectory .. "visualAnimals.xml")

		if xmlFile ~= nil then

			MVA_AnimalClusterHusbandry.MAX_HUSBANDRIES = xmlFile:getInt("settings#limit", 50)

			xmlFile:delete()

		end

	end

end

addModEventListener(RLMedium)