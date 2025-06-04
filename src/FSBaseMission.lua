MVA_FSBaseMission = {}


function MVA_FSBaseMission:onStartMission()

    local xmlFile = XMLFile.loadIfExists("MVASettings", modSettingsDirectory .. "Settings.xml")

    if xmlFile ~= nil then
        local maxHusbandries = xmlFile:getInt("Settings.setting(0)#maxHusbandries", 2)
        MVA_AnimalClusterHusbandry.MAX_HUSBANDRIES = maxHusbandries
        xmlFile:delete()
    end

end