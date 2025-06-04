MVA_AnimalClusterHusbandry = {}
MVA_AnimalClusterHusbandry.MAX_HUSBANDRIES = 50


function MVA_AnimalClusterHusbandry:create(_, xmlFilename, navigationNode, raycastDistance, collisionMask)

    if self.husbandryId ~= nil then
        self:deleteHusbandry()
    end

    self.navigationNode = navigationNode
    self.collisionMask = collisionMask
    self.xmlFilename = xmlFilename
    self.raycastDistance = raycastDistance
    self.visualAnimalCount = 0

    self.husbandries = {}

    for i = 1, 8 do

        local husbandry = createAnimalHusbandry(self.animalTypeName, navigationNode, xmlFilename, raycastDistance, CollisionMask.ANIMAL_POSITIONING, collisionMask, AudioGroup.ENVIRONMENT)

        if husbandry == 0 then
            Logging.error("Failed to create animal husbandry for %q with navigation mesh %q and config %q", self.animalTypeName, I3DUtil.getNodePath(navigationNode), xmlFilename)
            break
        end

        self.husbandries[i] = {
            ["id"] = husbandry,
            ["clusters"] = {},
            ["numAnimals"] = 0
        }

    end

    self.husbandryId = self.husbandries[1].id
    self.visualUpdatePending = true
    self:onIndoorStateChanged()

    return self.husbandryId

end

AnimalClusterHusbandry.create = Utils.overwrittenFunction(AnimalClusterHusbandry.create, MVA_AnimalClusterHusbandry.create)



function MVA_AnimalClusterHusbandry:deleteHusbandry()

    if self.husbandries ~= nil then

        for index, husbandry in pairs(self.husbandries) do

            for animalId, cluster in pairs(husbandry.clusters) do
                removeHusbandryAnimal(husbandry.id, animalId)
            end
            
            delete(husbandry.id)

        end

        g_soundManager:removeIndoorStateChangedListener(self)

        self.husbandries = nil
        self.husbandryId = nil

    end

end

AnimalClusterHusbandry.deleteHusbandry = Utils.overwrittenFunction(AnimalClusterHusbandry.deleteHusbandry, MVA_AnimalClusterHusbandry.deleteHusbandry)


function MVA_AnimalClusterHusbandry:updateVisuals()

    if self.husbandryId == nil or not isHusbandryReady(self.husbandryId) then
		self.visualUpdatePending = true
		return
	end

    local clusters = {}


    for _, cluster in pairs(self.nextUpdateClusters or {}) do

        local subTypeIndex = cluster:getSubTypeIndex()
		local age = cluster:getAge()

        local clusterToLoad = {
            ["cluster"] = cluster,
            ["totalAnimals"] = cluster:getNumAnimals(),
            ["animalsLoaded"] = 0,
            ["visualAnimal"] = self.animalSystem:getVisualByAge(subTypeIndex, age)
        }

        table.insert(clusters, clusterToLoad)

    end


    local totalVisualAnimals = 0


    for index, husbandry in pairs(self.husbandries) do

        local husbandryId = husbandry.id

        for animalId, _ in pairs(husbandry.clusters) do

            removeHusbandryAnimal(husbandryId, animalId)

        end

        husbandry.clusters = {}
        husbandry.numAnimals = 0

        for _, cluster in pairs(clusters) do

            for i = 1, cluster.totalAnimals do

                if totalVisualAnimals >= MVA_AnimalClusterHusbandry.MAX_HUSBANDRIES or husbandry.numAnimals >= 25 or cluster.animalsLoaded >= cluster.totalAnimals then break end

                local visualAnimal = cluster.visualAnimal
                local animalId = addHusbandryAnimal(husbandryId, visualAnimal.visualAnimalIndex - 1)

                if animalId == 0 then
				    Logging.error("Unable to add animal with visual index %d for husbandry %d", visualAnimal.visualAnimalIndex - 1, husbandryId)
			    else

				    local variations = visualAnimal.visualAnimal.variations

				    if #variations > 1 then
					    local variation = variations[math.random(1, #variations)]
					    setAnimalTextureTile(husbandryId, animalId, variation.tileUIndex, variation.tileVIndex)
				    end

                    local dirtFactor = (cluster.cluster.getDirtFactor == nil or not Platform.gameplay.needHorseCleaning) and 0 or cluster.cluster:getDirtFactor()
		            local animalRootNode = getAnimalRootNode(husbandryId, animalId)
		            local x, y, z, w = getAnimalShaderParameter(husbandryId, animalId, "atlasInvSizeAndOffsetUV")

		            I3DUtil.setShaderParameterRec(animalRootNode, "dirt", dirtFactor, nil, nil, nil)
		            I3DUtil.setShaderParameterRec(animalRootNode, "atlasInvSizeAndOffsetUV", x, y, z, w)

				    husbandry.clusters[animalId] = cluster.cluster
                    cluster.animalsLoaded = cluster.animalsLoaded + 1
                    husbandry.numAnimals = husbandry.numAnimals + 1
                    totalVisualAnimals = totalVisualAnimals + 1

			    end

            end

        end

    end
	
	self.nextUpdateClusters = nil

end

AnimalClusterHusbandry.updateVisuals = Utils.overwrittenFunction(AnimalClusterHusbandry.updateVisuals, MVA_AnimalClusterHusbandry.updateVisuals)


function MVA_AnimalClusterHusbandry:getAnimalPosition(_, id, husbandryId)

    for _, husbandry in pairs(self.husbandries) do

        if husbandry.id ~= husbandryId then continue end

        for animalId, cluster in pairs(husbandry.clusters) do

            if cluster.id == id then

                local x, y, z = getAnimalPosition(husbandryId, animalId)
			    local rx, ry, rz = getAnimalRotation(husbandryId, animalId)

			    return x, y, z, rx, ry, rz

            end

        end

    end

	return nil

end

AnimalClusterHusbandry.getAnimalPosition = Utils.overwrittenFunction(AnimalClusterHusbandry.getAnimalPosition, MVA_AnimalClusterHusbandry.getAnimalPosition)


function MVA_AnimalClusterHusbandry:getClusterByAnimalId(_, animalId, husbandryId)

    for _, husbandry in pairs(self.husbandries) do

        if husbandry.id ~= husbandryId then continue end

        for id, cluster in pairs(husbandry.clusters) do
            if id == animalId then return cluster end
        end

    end

    return nil

end

AnimalClusterHusbandry.getClusterByAnimalId = Utils.overwrittenFunction(AnimalClusterHusbandry.getClusterByAnimalId, MVA_AnimalClusterHusbandry.getClusterByAnimalId)