MVA_PlayerHUDUpdater = {}


function MVA_PlayerHUDUpdater:updateRaycastObject()

    if self.isAnimal == false and self.currentRaycastTarget ~= nil and entityExists(self.currentRaycastTarget) then

        local object = g_currentMission:getNodeObject(self.currentRaycastTarget)
        if object == nil then

            if not getHasClassId(self.currentRaycastTarget, ClassIds.MESH_SPLIT_SHAPE) then

                local husbandryId, animalId = getAnimalFromCollisionNode(self.currentRaycastTarget)

                if husbandryId ~= nil and husbandryId ~= 0 then

                    local clusterHusbandry = g_currentMission.husbandrySystem:getClusterHusbandryById(husbandryId)

                    if clusterHusbandry ~= nil then
                        local animal = clusterHusbandry:getClusterByAnimalId(animalId, husbandryId)

                        if animal ~= nil then
                            self.isAnimal = true
                            self.object = animal
                            return
                        end
                    end

                end

            end

        end

    end

end

PlayerHUDUpdater.updateRaycastObject = Utils.appendedFunction(PlayerHUDUpdater.updateRaycastObject, MVA_PlayerHUDUpdater.updateRaycastObject)