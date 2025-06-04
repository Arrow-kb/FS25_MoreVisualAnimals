MVA_HusbandrySystem = {}


function MVA_HusbandrySystem:getClusterHusbandryById(_, id)

    for _, clusterHusbandry in pairs(self.clusterHusbandries) do

        if clusterHusbandry.husbandries ~= nil then

            for _, husbandry in pairs(clusterHusbandry.husbandries) do
                if husbandry.id == id then return clusterHusbandry end
            end

        end

    end

    return nil

end

HusbandrySystem.getClusterHusbandryById = Utils.overwrittenFunction(HusbandrySystem.getClusterHusbandryById, MVA_HusbandrySystem.getClusterHusbandryById)