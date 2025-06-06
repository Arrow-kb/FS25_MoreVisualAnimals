RLMedium = {}

modDirectory = g_currentModDirectory
modSettingsDirectory = g_currentModSettingsDirectory


local files = {
	"src/animals/events/AnimalRidingEvent.lua",
	"src/animals/husbandry/cluster/AnimalClusterHusbandry.lua",
	"src/animals/husbandry/placeables/PlaceableHusbandryAnimals.lua",
	"src/animals/husbandry/HusbandrySystem.lua",
	"src/gui/VisualAnimalsDialog.lua",
	"src/handTools/specializations/HandToolHorseBrush.lua",
	"src/player/PlayerHUDUpdater.lua",
	"src/player/PlayerInputComponent.lua",
	"src/FSBaseMission.lua"
}


function RLMedium.loadMap()

	if not g_modIsLoaded["FS25_RealisticLivestock"] then

		for _, file in pairs(files) do source(modDirectory .. file) end

		local xmlFile = XMLFile.loadIfExists("visualAnimalsCap", modSettingsDirectory .. "visualAnimals.xml")

		if xmlFile ~= nil then

			MVA_AnimalClusterHusbandry.MAX_HUSBANDRIES = xmlFile:getInt("settings#limit", 50)

			xmlFile:delete()

		end

	end

end

addModEventListener(RLMedium)